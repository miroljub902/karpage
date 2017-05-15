Rails.application.routes.draw do
  apipie
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end if Rails.env.production?

  mount Sidekiq::Web => '/sidekiq'

  ActiveAdmin.routes(self)

  namespace :api, constraints: { subdomain: ENV.fetch('API_SUBDOMAIN') } do
    resource :session, only: %i(create destroy), path: 'session'
    resource :password_reset, path: 'password', only: %i(create update)
    resource :user, only: %i(show create update) do
      put :reset_counter
    end
    resources :notifications, only: :index
    resources :profiles, only: %i(index show), path: 'users', constraints: { id: /[^\/]+/ } do
      post :follow, on: :member
      delete :unfollow, on: :member
      resources :reports, only: :create, reportable_type: 'User', constraints: { profile_id: /[^\/]+/ }
      resource :block, only: :create, constraints: { profile_id: /[^\/]+/ }
      resources :friends, only: [] do
        get 'followers', on: :collection
        get 'following', on: :collection
      end
    end

    resources :businesses do
      resources :products
    end

    resources :filters, only: :index
    resources :cars, only: %i(index show create update destroy) do
      put :reset_counter

      resource :like, only: %i(create destroy), likeable_type: 'Car'
      resources :comments, commentable_type: 'Car'
      resources :reports, only: :create, reportable_type: 'Car'
      resources :car_parts, only: %i(create update destroy), path: 'parts', as: :parts
    end
    resources :posts, only: %i(index show create update destroy) do
      get 'user/:user_id' => 'posts#index', on: :collection, constraints: { user_id: /[^\/]+/ }
      get :feed, on: :collection
      resources :comments, commentable_type: 'Post'
      resource :like, only: %i(create destroy), likeable_type: 'Post'
      resources :reports, only: :create, reportable_type: 'Post'
      resource :upvote, only: %i[create destroy], voteable_type: 'Post'
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
      post :resort, on: :collection

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

  get 'posts/explore' => 'posts#explore'
  get 'posts/feed' => 'posts#feed'

  get ':profile_id' => 'profiles#show', as: :profile, constraints: { profile_id: /[^\/]+/ }
  scope ':profile_id', constraints: { profile_id: /[^\/]+/ } do
    post 'follow' => 'profiles#follow', as: :follow_user
    post 'unfollow' => 'profiles#unfollow', as: :unfollow_user
    get 'followers' => 'follows#index', followers: true, as: :user_followers
    get 'following' => 'follows#index', following: true, as: :user_followees

    resources :posts, only: %i(index show) do
      put 'like' => 'likes#toggle', as: :toggle_like, likeable_class: Post
    end

    get ':car_id' => 'profile_cars#show', as: :profile_car, constraints: { car_id: /[^\/]+/ }
    scope ':car_id', constraints: { car_id: /[^\/]+/ } do
      put 'like' => 'likes#toggle', as: :toggle_like_car, likeable_class: Car
    end
  end
end
