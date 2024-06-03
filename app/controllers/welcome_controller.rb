class WelcomeController < ApplicationController
  include RemotelyTranslatable

  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user
  before_action :authenticate_user!, only: :welcome

  layout "devise", only: [:welcome, :verification]

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body
    @banners = Banner.in_section("homepage").with_active
    @header_slides = HeaderSlide.homepage
    @remote_translations = detect_remote_translations(@feeds,
                                                      @recommended_debates,
                                                      @recommended_proposals)
    @current_budget = current_budget
    if @current_budget.present?
      @stats = Budget::Stats.new(@current_budget)
    end
    start_date = params.fetch(:start_date, Date.today).to_date
    date_range = start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week
    @events = Event.where(start_time: date_range).or(Event.where(end_time: date_range))
    if user_signed_in? 
      @complaint = Complaint.new
      @admin_unit = get_admin_unit
    end
  end

  def welcome
    if current_user.level_three_verified?
      redirect_to page_path("welcome_level_three_verified")
    elsif current_user.level_two_or_three_verified?
      redirect_to page_path("welcome_level_two_verified")
    else
      redirect_to page_path("welcome_not_verified")
    end
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  def create_complaint

    # Solo pueden enviar quejas y sugerencias los ciudadanos

    department_param = complaints_params['department']&.split('#', 3)
    department_id = department_param&.dig(0) # ideuni
    department_code = department_param&.dig(1) #coduni
    department = department_param&.dig(2) # departamento

    # Valores fijos por ahora:
    complaint_id = "457" # ideasun
    complaint_code = "63015" # codasuninst
    request_type = "Quejas y/o Sugerencias" # tipoSolicitud
    status = "Sin enviar" # ['Sin enviar', 'Enviado']

    @complaint = Complaint.new(user_id: current_user.id, 
      department_id: department_id, department_code: department_code, department: department, 
      complaint_id: complaint_id, complaint_code: complaint_code, request_type: request_type, 
      status: status, subject: complaints_params['subject'], body: complaints_params['body'])
    if @complaint.save

      if send_and_update_complaint(@complaint)
        notice = "Queja/sugerencia enviada correctamente!"
        redirect_to root_path, notice: notice
      else
        alert = "No se ha podido enviar la queja/sugerencia"
        redirect_to root_path, alert: alert
      end
    else
      alert = "Debe rellenar todos los campos de la queja/sugerencia"
      redirect_to root_path, alert: alert
    end

  end

  private

  def set_user_recommendations
    @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
    @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
  end

  def get_bus_token
    bus_settings = Rails.application.secrets.bus_settings

    token_url = bus_settings[:host]+bus_settings[:token_path]
    token_headers = {
      params: { grant_type: "client_credentials" },
      authorization: bus_settings[:token_header_authorization]
    }

    RestClient.log = STDOUT
    token_response = RestClient::Request.execute(
      method: :post,
      url: token_url, 
      timeout: 10,
      headers: token_headers,
      verify_ssl: false)

    if token_response.code == 200
      token_response_body = JSON.parse(token_response.body)
      token_response_body["token_type"] + ' ' + token_response_body["access_token"]
    else
      raise "Failed to get BUS Token. Response: #{token_response}"
    end
  end

  def get_admin_unit
    admin_unit = []
    begin
      token = get_bus_token

      bus_settings = Rails.application.secrets.bus_settings
      experta_settings = Rails.application.secrets.experta_settings

      data_url = bus_settings[:host]+experta_settings[:getuniadmi_path]
      # logger.info "data_url = '#{data_url}'"
      app = bus_settings[:app]
      action = experta_settings[:getuniadmi_action]
      xml = experta_settings[:getuniadmi_xml]
      data_payload = {app: app, action: action, xml: xml}.to_json
      data_headers = {content_type: :json, accept: :json, authorization: token}

      RestClient.log = STDOUT
      data_response = RestClient::Request.execute(
        method: :post,
        url: data_url, 
        payload: data_payload,
        timeout: 10,
        headers: data_headers,
        verify_ssl: false)
      
      if data_response.code == 200
        data_response_body = JSON.parse(data_response.body)
        #logger.info data_response_body
        response_xml = data_response_body.dig("Envelope", "Body", "servicioResponse", "servicioReturn")
        unidades = Nokogiri::XML(response_xml).xpath('/S/PAR/L_UNIDADES/UNIDAD')
        admin_unit = unidades.map { |unidad| [unidad.xpath('DESCRIPCION').text, unidad.xpath('ID').text+'#'+unidad.xpath('COD').text+'#'+unidad.xpath('DESCRIPCION').text] }.sort_by { |item| item[0] }
      else
        raise "Failed to get 'Unidad Administrativa'. Response: #{data_response}"
      end
    rescue Exception => e
        logger.error e
    end
    admin_unit
  end

  def send_and_update_complaint(complaint)
    value = false
    begin
      token = get_bus_token

      bus_settings = Rails.application.secrets.bus_settings
      experta_settings = Rails.application.secrets.experta_settings

      data_url = bus_settings[:host]+experta_settings[:sendcomplaint_path]
      # logger.info "data_url = '#{data_url}'"
      app = bus_settings[:app]

      data_payload = {
        app: app, 
        username: current_user.username, 
        payload: { 
          date: Date.today.strftime("%d/%m/%Y"),
          codasuninst: complaint.complaint_code,
          ideasun: complaint.complaint_id,
          ideuni: complaint.department_id,
          coduni: complaint.department_code,
          tramite:{
              tipoSolicitud: complaint.request_type,
              departamento: complaint.department,
              motivo: complaint.subject,
              descr: complaint.body
          }
        }
      }.to_json

      data_headers = {content_type: :json, accept: :json, authorization: token}

      RestClient.log = STDOUT
      data_response = RestClient::Request.execute(
        method: :post,
        url: data_url, 
        payload: data_payload,
        timeout: 10,
        headers: data_headers,
        verify_ssl: false)
      
      if data_response.code == 200
        data_response_body = JSON.parse(data_response.body)

        if data_response_body.dig("exito")
          
          request_number = data_response_body.dig("numSolicitud")
          exp_number = data_response_body.dig("numExp")
          request_name = data_response_body.dig("documentos",0,"nombre")
          request_code = data_response_body.dig("documentos",0,"cove")
          request = data_response_body.dig("documentos",0,"documento")
          response_name = data_response_body.dig("documentos",1,"nombre")
          response_code = data_response_body.dig("documentos",1,"cove")
          response = data_response_body.dig("documentos",1,"documento")

          # logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
          # logger.info "numSolicitud = #{numSolicitud}"
          # logger.info "numExp = #{numExp}"
          # logger.info "request_name = #{request_name}"
          # logger.info "request_code = #{request_code}"
          # logger.info "request = #{request}"
          # logger.info "response_name = #{response_name}"
          # logger.info "response_code = #{response_code}"
          # logger.info "response = #{response}"
          # logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

          complaint.update!(status: "Enviado", 
            request_name: request_name, request_code: request_code, request: request, 
            response_name: response_name, response_code: response_code, response: response,
            request_number: request_number, exp_number: exp_number)

          value = true
        else
          raise "Failed to send complaint. Response: #{data_response}"
        end
      end
    rescue Exception => e
        logger.error e
    end
    value #returned
  end

  def complaints_params
    attributes = [:request_type, :department, :subject, :body]
    params.require(:complaint).permit(attributes)
  end

end
