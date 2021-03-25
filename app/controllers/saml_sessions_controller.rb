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
      #redirect_to new_user_session_path
      redirect_to new_saml_user_session_path(issuer: Settings.identity_providers.citizen_issuer)
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(@saml_config)
  end

  def create
    begin
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
