resources :satisfaction_surveys, only: [:index]
post "/satisfaction_surveys/answer", to: "satisfaction_surveys#answer"

resources :satisfaction_surveys_digital_province, only: [:index]
post "/satisfaction_surveys_digital_province/answer", to: "satisfaction_surveys_digital_province#answer"