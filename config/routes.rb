Rails.application.routes.draw do
  resources :merchants

  namespace :api do
    defaults format: :json do
      post 'transactions', to: 'transactions#create'
    end
  end
end
