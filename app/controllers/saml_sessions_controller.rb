require 'idp_settings_adapter'
require 'json'
require 'rest-client'
require 'date'

class SamlSessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_issuer

  def init
    if params[:issuer]
      request = OneLogin::RubySaml::Authrequest.new
      settings = IdpSettingsAdapter.saml_settings(@issuer)
      action = request.create(settings)
      redirect_to action
    else
      #redirect_to new_user_session_path
      redirect_to login_saml_user_path(issuer: Settings.identity_providers.citizen_issuer)
    end
  end

  def login_city_hall_user
    redirect_to login_saml_user_path(issuer: Settings.identity_providers.city_hall_issuer)
  end

  def consume
    redirect_path = root_path
    begin
      logger.info "request.host = #{request.env['rack.url_scheme']}://#{request.host_with_port}"
      settings = IdpSettingsAdapter.saml_settings(@issuer)
      response_to_validate = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: settings)
    
      #puts "settings = #{settings.to_json}"
      #puts "params[:SAMLResponse] = [#{params[:SAMLResponse]}]"
      #puts "settings.certificate = #{settings.certificate}"
      #puts "settings.private_key = #{settings.private_key}"
      #puts "response_to_validate.is_valid = #{response_to_validate.is_valid?}"
      #puts "response_to_validate.nameid = #{response_to_validate.nameid}"
      
      logger.info "SessionIndex = '#{response_to_validate.sessionindex}'"

      if response_to_validate.is_valid? && username = response_to_validate.nameid.downcase

        session[:saml_session_index] = response_to_validate.sessionindex

        if @issuer == Settings.identity_providers.citizen_issuer
          # Es ciudadano, se obtienen los datos del CRM
          crm_attributes = get_crm_user_data(username)

          if user = User.find_by(username: username)
            # Usuario existente, se actualiza con los datos del CRM
            user = update_citizen(user, crm_attributes)
          else
            # Usuario nuevo, se inserta con los datos del CRM
            user = create_citizen(username, crm_attributes)
          end
        elsif @issuer == Settings.identity_providers.city_hall_issuer
          # Es Ayto.
          unless user = User.find_by(username: username)
            raise "Could not login as city hall user: Username '#{username}' does not exist"
          end
          if user.administrator?
            redirect_path = admin_root_path
          elsif user.moderator?
            redirect_path = moderation_root_path
          elsif user.valuator?
            redirect_path = valuation_root_path
          end
        else
          raise "Login failed: Unknown issuer"
        end

        sign_in user
        session[:saml_issuer] = @issuer
        flash[:notice] = t("devise.sessions.signed_in")
        redirect_to redirect_path
      else
        raise "SAMLResponse is invalid or username does not exist"
      end
    rescue Exception => e
      exception_msg = "Exception: #{e} - #{e.backtrace.select {|x| x.match("/app/controllers")}}"
      Rails.logger.error exception_msg
      LoginError.create(issuer: @issuer, username: username, error: exception_msg)
      flash[:error] = t("flash.actions.error.login")
      redirect_to root_path
    end
  end

  def logout_old
    #redirect_address = new_user_session_path
    redirect_address = root_path 
    if session[:saml_issuer]
      #redirect_address = IdpSettingsAdapter.get_idp_homepage(session[:saml_issuer])
      redirect_address = IdpSettingsAdapter.get_idp_homepage
      session[:saml_issuer] = nil
    end
    sign_out current_user
    respond_to do |format|
      format.js { render partial: 'logout', locals: {redirect_address: redirect_address} }
    end
  end

  # Activar solicitudes de logout iniciadas por SP e IdP
  def logout
    # Si recibe una solicitud del IdP
    if params[:SAMLRequest]
      return idp_logout_request
    # Si recibe una respuesta del IdP
    elsif params[:SAMLResponse]
      return process_logout_response
    # Iniciar SLO (enviar solicitud de logout)
    else
      return sp_logout_request
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    settings = IdpSettingsAdapter.saml_settings(@issuer)
    render :xml => meta.generate(settings)
  end

  protected

  def relay_state
    @relay_state ||= if Devise.saml_relay_state.present?
                       Devise.saml_relay_state.call(request)
                     end
  end

  private

  # Crer un SLO iniciado por SP
  def sp_logout_request
    # LogoutRequest acepta solicitudes simples del navegador sin parametros
    settings = IdpSettingsAdapter.saml_settings(@issuer)

    logged_user = current_user

    #if settings.idp_slo_service_url.nil?
    #  logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
    #  delete_session
    #else

    logout_request = OneLogin::RubySaml::Logoutrequest.new()
    logger.info "New SP SLO for user '#{logged_user.username}' transactionid '#{logout_request.uuid}'"

    if settings.name_identifier_value.nil?
      settings.name_identifier_value = logged_user.username
    end

    settings.sessionindex = session[:saml_session_index]

    # Asegurar que el usuario haya cerrado sesion antes de redirigirlo al IdP, en caso de que algo salga mal durante el proceso de cierre de sesion unico (segun lo recomendado por saml2int[SDP-SP34])
    #logger.info "Delete session for '#{logged_user.username}'"
    #delete_session

    # Guardar el transaction_id para compararlo al volver con la respuesta
    session[:transaction_id] = logout_request.uuid
    session[:logged_out_user] = logged_user

    relayState =  url_for controller: 'saml_sessions', action: 'logout'
    #relayState = root_path
    logout_request_created = logout_request.create(settings, :RelayState => relayState)
    
    #settings.assertion_consumer_service_url = url_for controller: 'saml_sessions', action: 'logout'
    #logout_request_created = logout_request.create(settings)

    #logger.info "#{logout_request_created}"
    #respond_to do |format|
    #  format.js { render partial: 'logout', locals: {redirect_address: logout_request_created} }
    #end

    #respond_to do |format|
    #  format.js { redirect_to logout_request_created, turbolinks: false }
    #end

    #redirect_to logout_request_created

    respond_to do |format|
      format.html { redirect_to logout_request_created }
      format.js { render :js => "window.location.href='"+logout_request_created+"'" }
    end

    #end
  end

  # Despues de enviar una LogoutRequest iniciada por el SP, 
  # debemos aceptar la LogoutResponse, verificarla y eliminarla de sesion
  def process_logout_response
    settings = IdpSettingsAdapter.saml_settings(@issuer)
    #settings.sp_entity_id = @issuer

    if session.has_key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transaction_id])
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end

    logger.info "LogoutResponse is: #{logout_response.response.to_s}"

    # Validar la respuesta de cierre de sesion de SAML
    if not logout_response.validate
      logger.error "The SAML Logout Response is invalid. Errors: #{logout_response.errors}"
      flash[:error] = t("devise.sessions.signed_out")
      redirect_to root_path
    else
      # Cierre la sesion
      if logout_response.success?
        logger.info "SLO completed for '#{session[:logged_out_user]['username']}'"
        delete_session
        flash[:notice] = t("devise.sessions.signed_out")
        redirect_to root_path
      else
        # Mensaje
      end
    end
  end

  # Elimina la sesion de un usuario
  def delete_session
    session[:userid] = nil
    session[:transaction_id] = nil
    session[:logged_out_user] = nil
    session[:saml_issuer] = nil
    sign_out current_user
  end

  # Metodo para manejar los logout iniciados por IdP
  def idp_logout_request
    settings = IdpSettingsAdapter.saml_settings(@issuer)
    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
    if !logout_request.is_valid?
      logger.error "IdP initiated LogoutRequest was not valid!"
      return render :inline => logger.error
    end
    logger.info "IdP initiated Logout for #{logout_request.name_id}"

    # Cierre la sesion
    delete_session

    # Genera una respuesta al IdP
    logout_request_id = logout_request.id
    logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, :RelayState => params[:RelayState])
    redirect_to logout_response
  end

  #def logger_errors(errors)
  #  Rails.logger.error "Error: #{errors.full_messages}"
  #  Rails.logger.error "Error details: #{errors.details}"
  #end

  def create_citizen (username, crm_attributes)
    logger.info "create_citizen xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    user_params = crm_user_params(username, crm_attributes)
    user = User.new(user_params)
    user.save!

    organization_params = crm_organization_params(user, crm_attributes)
    if organization_params.present?
      organization = Organization.new(organization_params)
      organization.save!
    end

    user
  end

  def update_citizen (user, crm_attributes)
    logger.info "update_citizen xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    user_params = crm_user_params(user.username, crm_attributes)
    logger.info "user_params = '#{user_params}'"
    user.update!(user_params)
   
    organization_params = crm_organization_params(user, crm_attributes)
    if organization_params.present?
      if organization = Organization.find_by(user: user)
        organization.update!(organization_params)
      else
        organization = Organization.new(organization_params)
        organization.save!
      end
    end

    user
  end

  def crm_user_params(username, crm_attributes)
    email = crm_attributes.dig("email")
    document_type = crm_attributes.dig("person", "identificationType", "value")
    document_number = crm_attributes.dig("person", "identificationDoc")
    gender = crm_attributes.dig("person", "genre", "value")
    birthDate = crm_attributes.dig("person", "censusData", "birthDate")
    date_of_birth = birthDate.present? ? Time.at(birthDate/1000).to_datetime : DateTime.new(1000,1,1)
    logger.info "date_of_birth = '#{date_of_birth}'"
    geozone_code = crm_attributes.dig("person", "censusData", "district")

    
    # citizen_type:
    # "PF": Persona física (Ciudadanos de Santander)
    # "PFA": Persona física autónomo
    # "PFEMB": Persona física – Embajador
    # "PFGUI": Persona jurídica – Guía
    # "PJA": Persona jurídica – Asociación
    # "PJAYTO": Persona jurídica – Ayuntamiento
    # "PJC": Persona jurídica – Colegio
    # "PJFUN": Persona jurídica – Fundación
    # "PJPRI": Persona jurídica - Empresa privada
    # "PJPUB": Persona jurídica - Empresa pública
    # "PJUNI": Persona jurídica – Universidad
    citizen_type = crm_attributes.dig("person", "personType", "value")
    unless ["PF","PFA","PFEMB","PFGUI","PJA","PJAYTO","PJC","PJFUN","PJPRI","PJPUB","PJUNI"].include?(citizen_type)
      raise "Could not login: Username '#{username}' is not a valid person_type in CRM"
    end

    case document_type
    when "nif", "dni", "cif"
      document_type = "1"
    when "pasaporte"
      document_type = "2"
    when "tarjResidencia"
      document_type = "3"
    else
      document_type = nil
    end

    case gender
    when "M"
      gender = "male"
    when "F"
      gender = "female"
    else
      gender = "unknown"
    end

    user_params = {
      username: username,
      password: SecureRandom.base58(24),
      email: email,
      document_type: document_type,
      document_number: document_number,
      created_from_signature: true,
      confirmed_at: Time.current,
      terms_of_service: true,
      date_of_birth: date_of_birth,
      gender: gender,
      geozone: Geozone.find_by(external_code: geozone_code),
      citizen_type: citizen_type}
  end

  def crm_organization_params(user, crm_attributes)
    organization_params = nil
    if user.citizen_type != "PF"
      organization_responsible_name = crm_attributes.dig("person", "representantes", 0, "name")
      organization_name = crm_attributes.dig("person", "name")
      organization_params = {
        user: user, 
        responsible_name: organization_responsible_name, 
        name: organization_name}
    end
    organization_params
  end

  def get_crm_user_data (username)
    
    logger.info "get_crm_user_data xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    # get crm token
    crm_settings = Rails.application.secrets.crm_settings
    token_url = crm_settings[:token_url]
    token_headers = {
      params: { grant_type: "client_credentials" },
      authorization: crm_settings[:token_header_authorization]
    }

    RestClient.log = STDOUT
    token_response = RestClient::Request.execute(
      method: :post,
      url: token_url, 
      timeout: 10,
      headers: token_headers,
      verify_ssl: false)

    # logger.info "token_response = '#{token_response}'"

    if token_response.code == 200

      # get crm user data
      data_url = "#{crm_settings[:data_url]}/#{username}"
      token_response_body = JSON.parse(token_response.body)
      data_body_app = crm_settings[:data_body_app]
      token_type = token_response_body["token_type"]
      token_secret = token_response_body["access_token"]
      data_header_authorization = "#{token_type} #{token_secret}"
      data_body_token = crm_settings[:data_body_token]
      data_payload =  "{'app': '#{data_body_app}', 'token': '#{data_body_token}'}"
      data_headers = {
        params: { getperson: "true" },
        content_type: :json,
        accept: :json,
        authorization: data_header_authorization
      }

      data_response = RestClient::Request.execute(
        method: :post,
        url: data_url, 
        payload: data_payload,
        timeout: 10,
        headers: data_headers,
        verify_ssl: false)

      # logger.info "data_response = '#{data_response}'"

      if data_response.code == 200
        # Return crm_attributes
        JSON.parse(data_response.body)
      else
        raise "Failed to get CRM Data. Response: #{data_response}"
      end

    else
      raise "Failed to get CRM Token. Response: #{token_response}"
    end

  end

  def set_issuer
    if params[:issuer]
      @issuer = params[:issuer]
      #puts "params[:issuer] = #{@issuer}"
    elsif session[:saml_issuer]
      @issuer = session[:saml_issuer]
    elsif params[:SAMLRequest]
      @issuer = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest]).issuer
      #puts "params[:SAMLRequest].issuer = #{@issuer}"
    elsif params[:SAMLResponse]
      response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
      begin
        @issuer = response.audiences.first
        #puts "response.audiences.first = #{response.audiences.first}"
      rescue Exception
        if logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse])
          if logout_response.success?
            @issuer = logout_response.issuer
            #puts "logout_response.issuer = #{@issuer}"
          end
        end
      end
    end
    logger.info "@issuer = #{@issuer}"
  end
end
