class IdpSettingsAdapter
  def self.saml_settings(issuer)
  	settings = Settings.identity_providers.onelogin
    settings["issuer"] = issuer
    settings["idp_cert"] = Rails.application.secrets.idp_cert
    settings["certificate"] = Rails.application.secrets.certificate
    settings["private_key"] = Rails.application.secrets.private_key
    return OneLogin::RubySaml::Settings.new(settings)
  end

  def self.get_idp_name
    return 'onelogin'
  end

  def self.get_idp_homepage
    return eval("Settings.identity_providers.onelogin.idp_homepage")
  end
end