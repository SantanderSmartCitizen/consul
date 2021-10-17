RouteTranslator.config do |config|
  config.force_locale = true
  config.hide_locale = true
  config.generate_unlocalized_routes = false
  config.generate_unnamed_unlocalized_routes = false
  config.locale_param_key = :my_locale
end
