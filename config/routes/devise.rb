devise_for :users, skip: [:sessions, :registrations, :passwords, :password_expired, :confirmations, :omniauth_callbacks]
devise_scope :user do
  get 'users/saml/sign_in' => 'saml_sessions#init', as: :login_saml_user
  post 'users/saml/auth' => 'saml_sessions#consume', as: :consume_saml_user
  match 'users/saml/sign_out' => 'saml_sessions#logout', as: :logout_saml_user, via: [:get, :post]
  get 'users/saml/metadata' => 'saml_sessions#metadata', as: :metadata_saml_user
  get 'gestion' => 'saml_sessions#login_city_hall_user', as: :login_city_hall_user
end
