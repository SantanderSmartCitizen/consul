Rails.application.routes.draw do

  mount Ckeditor::Engine => "/ckeditor"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  localized do
    draw :budget
    draw :debate
    draw :forum
    draw :gamification
    draw :legislation
    draw :poll
    draw :proposal
  end

  draw :account
  draw :admin
  draw :annotation
  draw :comment
  draw :community
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :related_content
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/consul.json", to: "installation#details"

  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]
  resources :remote_translations, only: [:create]
  resources :milestones, only: [:show] do
    member do
      post :vote
    end
  end

  localized do
    # More info pages
    get "help",             to: "pages#show", id: "help/index",             as: "help"
    get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
    get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"
    
    # Static pages
    resources :pages, path: "/", only: [:show]
  end

end
