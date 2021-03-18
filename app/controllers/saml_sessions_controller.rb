require 'idp_settings_adapter'

class SamlSessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_issuer

  def new
    if params[:issuer]
      request = OneLogin::RubySaml::Authrequest.new
      action = request.create(@saml_config)
      redirect_to action
    else
      redirect_to new_user_session_path
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(@saml_config)
  end

  def create
    response_to_validate = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: @saml_config)
  
    #puts "@saml_config = #{@saml_config.to_json}"
    #puts "params[:SAMLResponse] = [#{params[:SAMLResponse]}]"
    #puts "@saml_config.certificate = #{@saml_config.certificate}"
    #puts "@saml_config.private_key = #{@saml_config.private_key}"
    #puts "response_to_validate.is_valid = #{response_to_validate.is_valid?}"
    #puts "response_to_validate.nameid = #{response_to_validate.nameid}"
  
    if response_to_validate.is_valid? && username = response_to_validate.nameid
      session[:saml_issuer] = @issuer
      if @issuer == Settings.identity_providers.citizen_issuer
        if user = User.find_by(username: username)
          sign_in user
        else
          sign_in create_citizen(username, response_to_validate.attributes)
        end
        flash[:notice] = t("devise.sessions.signed_in")
      elsif @issuer == Settings.identity_providers.city_hall_issuer
        if user = User.find_by(username: username)
          sign_in user
          flash[:notice] = t("devise.sessions.signed_in")
        else
          flash[:error] = t("flash.actions.error.login")
        end
      else
        flash[:error] = t("flash.actions.error.login")
      end

      redirect_to root_path
    else
      #redirect_to new_user_session_path
      flash[:error] = t("flash.actions.error.login")
      redirect_to root_path 
    end
  end

  protected

  def relay_state
    @relay_state ||= if Devise.saml_relay_state.present?
                       Devise.saml_relay_state.call(request)
                     end
  end

  def generate_idp_logout_response(saml_config, logout_request_id)
    OneLogin::RubySaml::SloLogoutresponse.new.create(saml_config, logout_request_id, nil)
  end

  private

  def create_citizen (username, attributes)
    email = attributes[Settings.identity_providers.attribute.email]
    document_type = attributes[Settings.identity_providers.attribute.document_type]
    document_number = attributes[Settings.identity_providers.attribute.document_number]
    gender = attributes[Settings.identity_providers.attribute.gender]
    date_of_birth = attributes[Settings.identity_providers.attribute.date_of_birth]
    geozone_code = attributes[Settings.identity_providers.attribute.geozone_code]

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
    when "V"
      gender = "male"
    when "M"
      gender = "female"
    else
      gender = "unknown"
    end

    user_params = {
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
      geozone: Geozone.find_by(external_code: geozone_code)
    }
    User.create!(user_params)
  end

  def set_issuer
    if params[:issuer]
      @issuer = params[:issuer]
      #puts "params[:issuer] = #{@issuer}"
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
    #@saml_config = IdpSettingsAdapter.saml_settings(@idp_entity_id)
    @saml_config = IdpSettingsAdapter.saml_settings(@issuer)
  end
end
