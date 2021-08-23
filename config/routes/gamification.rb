namespace :gamification do
	resources :rewards, only: [:show] do
		member do
			post :execute
			post :unexecute
			post :create_request
		end
	end
end