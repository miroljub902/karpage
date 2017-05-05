class Api::UsersController < ApiController
  before_action :require_user, except: :create
  after_action :track_signup, only: :create, if: -> { @user.persisted? }

  def create
    @user = User.create user_params
    respond_with @user, status: :created
  end

  COUNTERS = {
    'friends_posts' => -> (user) { NewStuff.reset_count(user.friends_posts, user, owner: nil) },
    'followers' => -> (user) { NewStuff.reset_count(user.follows_by, user, owner: user) }
  }

  def reset_counter
    return render(nothing: true, status: :not_found) unless COUNTERS.has_key?(params[:counter])
    COUNTERS[params[:counter]].call current_user
    render nothing: true, status: :ok
  end

  def update
    @user = current_user
    @user.update_attributes user_params
    respond_with @user
  end

  def show
    @user = current_user
    respond_with @user
  end

  private

  def track_signup
    os = Browser.new(request.headers['User-Agent']).platform.name.downcase
    # Future usage:
    _res, _density = request.headers['X-Resolution'].to_s.split('@')
    GATracker.event! @user, category: 'user', action: 'signup', label: os, value: 1
  end

  def user_params
    params.require(:user).permit(
      :email, :login, :password, :facebook_token, :location, :description, :link, :name,
      :avatar_id, :avatar_content_type, :avatar_size, :avatar_filename, :instagram_id,
      :profile_background_id, :profile_background_content_type, :profile_background_size, :profile_background_filename,
      dream_cars_attributes: %i(id _destroy image_id image_content_type image_size image_filename),
      next_car_attributes: %i(id _destroy image_id image_content_type image_size image_filename),
      push_settings: User::DEFAULT_PUSH_SETTINGS.keys
    ).merge(password_confirmation: params[:user][:password])
  end
end
