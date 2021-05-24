Rails.application.routes.draw do
  resources :merchants

  namespace :api do
    defaults format: :json do
      post 'transactions', to: 'transactions#create'
      post 'auth/login', to: 'auth#login'
    end
  end
end
