Rails.application.routes.draw do
  root to: 'home#index'

  get 'auth/:provider/callback', to: 'user_sessions#create'
  get 'auth/failure', to: redirect('/')

  resource :user, only: %i(show new create edit update)
  resource :user_session, only: %i(new create destroy), path: 'session'
end
