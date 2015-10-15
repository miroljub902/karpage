Rails.application.routes.draw do
  root to: 'home#index'

  resource :user, only: %i(show new create update)
  resource :user_session, only: %i(new create destroy), path: 'session'
end
