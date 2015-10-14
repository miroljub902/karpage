Rails.application.routes.draw do
  root to: 'home#index'

  resource :user_session, only: %i(new create destroy), path: 'session'
end
