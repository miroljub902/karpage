Rails.application.routes.draw do
  root to: 'home#index'

  get 'auth/:provider/callback', to: 'user_sessions#create'
  get 'auth/failure', to: redirect('/')

  resource :user, only: %i(new create edit update) do
    resource :password_reset, path: 'password', only: %i(new create edit update)
    resources :user_cars, path: 'cars', as: :cars do
      resources :car_photos, path: 'photos', as: :photos, only: %i(create destroy) do
        post 'reorder', on: :collection
      end

      resources :comments, only: %i(create destroy), scope: :car
    end

    resources :car_singles, path: 'singles', as: :singles, only: %i(new create destroy)
    resources :posts, only: %i(new create edit update destroy)
  end
  resource :user_session, only: %i(new create destroy), path: 'session'

  get 's3_signatures_path' => 's3_signatures#create', as: :s3_signatures

  resources :pages, only: :show, path: 'info'

  get ':profile_id' => 'profiles#show', as: :profile
  scope ':profile_id' do
    resources :posts, only: %i(index show)

    get ':car_id' => 'profile_cars#show', as: :profile_car
  end
end
