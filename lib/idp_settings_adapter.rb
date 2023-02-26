class IdpSettingsAdapter
  def self.saml_settings(issuer)
  	settings = Settings.identity_providers.onelogin
    settings["sp_entity_id"] = issuer
    settings["idp_cert"] = Rails.application.secrets.idp_cert
    settings["certificate"] = Rails.application.secrets.certificate
    settings["private_key"] = Rails.application.secrets.private_key
    full_domain_path = Rails.application.secrets.server_protocol + '://' + Rails.application.secrets.server_name
    # full_domain_path = request.env['rack.url_scheme'] + '://' + request.host_with_port
    settings["assertion_consumer_service_url"] = full_domain_path + '/users/saml/auth'
    settings["single_logout_service_url"] = full_domain_path + '/users/saml/sign_out'

    return OneLogin::RubySaml::Settings.new(settings)
  end

  def self.get_idp_name
    return 'onelogin'
  end

  def self.get_idp_homepage
    return eval("Settings.identity_providers.onelogin.idp_homepage")
  end
end