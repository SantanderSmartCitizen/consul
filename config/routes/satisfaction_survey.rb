resources :satisfaction_surveys, only: [:index]
post "/satisfaction_surveys/answer", to: "satisfaction_surveys#answer"
