resources :forums do
  member do
    post :vote
    put :flag
    put :unflag
    put :mark_featured
    put :unmark_featured
  end

  collection do
    get :map
    get :suggest
    put "recommendations/disable", only: :index, controller: "forums", action: :disable_recommendations
  end
end
