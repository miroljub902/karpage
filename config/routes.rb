Rails.application.routes.draw do
  root to: 'home#index'

  get 'auth/:provider/callback', to: 'user_sessions#create'
  get 'auth/failure', to: redirect('/')

  resource :user, only: %i(show new create edit update) do
    resource :password_reset, path: 'password', only: %i(new create edit update)
    resources :user_cars, path: 'cars', as: :cars do
      resources :car_photos, path: 'photos', as: :photos, only: %i(create destroy)
    end
  end
  resource :user_session, only: %i(new create destroy), path: 'session'

  get 's3_signatures_path' => 's3_signatures#create', as: :s3_signatures
end
