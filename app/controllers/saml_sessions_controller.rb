require 'idp_settings_adapter'

class SamlSessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_issuer

  def init
    if params[:issuer]
      request = OneLogin::RubySaml::Authrequest.new
      action = request.create(@saml_settings)
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
    begin
      response_to_validate = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: @saml_settings)
    
      #puts "@saml_settings = #{@saml_settings.to_json}"
      #puts "params[:SAMLResponse] = [#{params[:SAMLResponse]}]"
      #puts "@saml_settings.certificate = #{@saml_settings.certificate}"
      #puts "@saml_settings.private_key = #{@saml_settings.private_key}"
      #puts "response_to_validate.is_valid = #{response_to_validate.is_valid?}"
      #puts "response_to_validate.nameid = #{response_to_validate.nameid}"
      
      if response_to_validate.is_valid? && username = response_to_validate.nameid
        session[:saml_issuer] = @issuer

        if @issuer == Settings.identity_providers.citizen_issuer
          if user = User.find_by(username: username)
            unless user.citizen_type
              raise "Could not login as citizen: Username '#{username}' exist but is not a citizen"
            end
          else
            user = create_citizen(username, response_to_validate.attributes)
          end
        elsif @issuer == Settings.identity_providers.city_hall_issuer
          unless user = User.find_by(username: username)
            raise "Could not login as city hall user: Username '#{username}' does not exist"
          end
        else
          raise "Login failed: Unknown issuer"
        end

        sign_in user
        flash[:notice] = t("devise.sessions.signed_in")
        redirect_to root_path
      else
        raise "SAMLResponse is invalid or username does not exist"
      end
    rescue Exception => e
      Rails.logger.error "Exception: #{e}"
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
    render :xml => meta.generate(@saml_settings)
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

    #puts "@saml_settings = #{@saml_settings.to_json}"

    # LogoutRequest acepta solicitudes simples del navegador sin parametros
    settings = @saml_settings
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

    # Asegurar que el usuario haya cerrado sesion antes de redirigirlo al IdP, en caso de que algo salga mal durante el proceso de cierre de sesion unico (segun lo recomendado por saml2int[SDP-SP34])
    logger.info "Delete session for '#{logged_user.username}'"
    delete_session

    # Guardar el transaction_id para compararlo al volver con la respuesta
    session[:transaction_id] = logout_request.uuid
    session[:logged_out_user] = logged_user

    relayState =  url_for controller: 'saml_sessions', action: 'logout'
    #relayState = root_path
    logout_request_created = logout_request.create(settings, :RelayState => relayState)
    
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

  # Despues de enviar una LogoutRequest iniciada por el SP al IdP, 
  # debemos aceptar la LogoutResponse, verificarla y eliminarla de sesion
  def process_logout_response
    settings = @saml_settings

    if session.has_key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transaction_id])
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end

    logger.info "LogoutResponse is: #{logout_response.to_s}"

    # Validar la respuesta de cierre de sesion de SAML
    if not logout_response.validate
      logger.error "The SAML Logout Response is invalid"
    else
      # Cierre la sesion
      logger.info "SLO completed for '#{session[:logged_out_user]}'"
      delete_session
    end
  end

  # Elimina la sesion de un usuario
  def delete_session
    session[:userid] = nil
    session[:attributes] = nil
    session[:transaction_id] = nil
    session[:logged_out_user] = nil
    session[:saml_issuer] = nil
    sign_out current_user
  end

  # Metodo para manejar los logout iniciados por IdP
  def idp_logout_request
    settings = @saml_settings
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

  def create_citizen (username, attributes)
    email = attributes[Settings.identity_providers.attributes.email]
    document_type = attributes[Settings.identity_providers.attributes.document_type]
    document_number = attributes[Settings.identity_providers.attributes.document_number]
    gender = attributes[Settings.identity_providers.attributes.gender]
    date_of_birth = attributes[Settings.identity_providers.attributes.date_of_birth]
    geozone_code = attributes[Settings.identity_providers.attributes.geozone_code]
    citizen_type = attributes[Settings.identity_providers.attributes.user_type]
    organization_name = attributes[Settings.identity_providers.attributes.organization_name]
    organization_responsible_name = attributes[Settings.identity_providers.attributes.organization_responsible_name]

    case document_type
    when "NIF", "DNI", "NIE"
      document_type = "1"
    when "Pasaporte"
      document_type = "2"
    when "Tarjeta Residencia"
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

    user = User.new(
      username: username,
      email: email,
      password: SecureRandom.base58(24),
      document_type: document_type,
      document_number: document_number,
      created_from_signature: true,
      confirmed_at: Time.current,
      terms_of_service: true,
      date_of_birth: date_of_birth.to_datetime,
      gender: gender,
      geozone: Geozone.find_by(external_code: geozone_code),
      citizen_type: citizen_type)

    user.save!
    if ["02","03","04"].include?(citizen_type)
      organization = Organization.new(
        user: user, 
        responsible_name: organization_responsible_name, 
        name: organization_name)
      organization.save!
    end
    user
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
    #@saml_settings = IdpSettingsAdapter.saml_settings(@idp_entity_id)
    @saml_settings = IdpSettingsAdapter.saml_settings(@issuer)
  end
end
