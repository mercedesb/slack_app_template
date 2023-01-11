Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  root "application#index"
  get '/oauth' => 'oauth#index'
  get '/oauth/callback' => 'oauth#callback'

  resource :slash_command, only: [] do
    post :robin, on: :member, path: '/'
  end

  resource :event, only: [] do
    post :incoming, on: :member, path: '/'
  end
end
