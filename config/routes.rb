Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  namespace :api, constraints: { subdomain: ENV.fetch('API_SUBDOMAIN') } do
    resource :session, only: %i(create destroy), path: 'session'
    resource :user, only: %i(show create update)
    resources :profiles, only: %i(show), path: 'users'
    resources :cars, only: %i(index show create update destroy) do
      resource :like, only: %i(create destroy), likeable_type: 'Car'
    end
    resources :posts, only: %i(index show create update destroy) do
      get 'user/:user_id' => 'posts#index'
    end
  end

  scope constraints: { subdomain: ENV.fetch('API_SUBDOMAIN') } do
    match '*unmatched', to: 'api#route_options', via: :options
  end

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
    resources :posts, only: %i(new create edit update destroy) do
      resources :comments, only: %i(create destroy), scope: :post
    end
  end
  resource :user_session, only: %i(new create destroy), path: 'session'

  get 's3_signatures_path' => 's3_signatures#create', as: :s3_signatures

  get 'contact' => 'contact_form#new', as: :contact_form
  post 'contact' => 'contact_form#create'

  resources :pages, only: :show, path: 'info'
  resources :profile_cars, only: :index, path: 'cars'
  resources :profiles, only: :index, path: 'users'

  get 'posts/feed' => 'posts#feed'

  get ':profile_id' => 'profiles#show', as: :profile
  scope ':profile_id' do
    post 'follow' => 'profiles#follow', as: :follow_user
    post 'unfollow' => 'profiles#unfollow', as: :unfollow_user
    get 'followers' => 'follows#index', followers: true, as: :user_followers
    get 'following' => 'follows#index', following: true, as: :user_followees

    resources :posts, only: %i(index show)

    get ':car_id' => 'profile_cars#show', as: :profile_car
    scope ':car_id' do
      put 'like' => 'likes#toggle', as: :toggle_like_car, likeable_class: Car
    end
  end
end
