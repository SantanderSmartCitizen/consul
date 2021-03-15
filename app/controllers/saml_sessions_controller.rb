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
  
    puts "response_to_validate.is_valid = #{response_to_validate.is_valid?}"
    puts "response_to_validate.nameid = #{response_to_validate.nameid}"
  
    if response_to_validate.is_valid? && email = response_to_validate.nameid
      session[:saml_issuer] = @issuer
      
      if user = User.find_by(username: email)
        puts "----> sign_in: user"
        sign_in user
      else
        puts "----> sign_in: User.create"
        puts "email = #{email}"
        sign_in User.create!(username: email, email: email, password: SecureRandom.base58(24))
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

  def set_issuer
    if params[:issuer]
      @issuer = params[:issuer]
    elsif params[:SAMLRequest]
      @issuer = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest]).issuer
    elsif params[:SAMLResponse]
      response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
      begin
        @issuer = response.issuers.first
      rescue Exception
        if logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse])
          if logout_response.success?
            @issuer = logout_response.issuer
          end
        end
      end
    end
    #@saml_config = IdpSettingsAdapter.saml_settings(@idp_entity_id)
    @saml_config = IdpSettingsAdapter.saml_settings(@issuer)
  end
end
