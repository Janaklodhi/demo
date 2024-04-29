Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  post '/users/signup', to: 'users#signup'
  post '/users/login', to: 'users#login'
  post '/users/forgot_password', to: 'users#forgot_password'
  patch '/users/reset_password/:token', to: 'users#reset_password', as: 'reset_password_token'
end
