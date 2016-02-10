class Api::UsersController < ApiController
  before_action :require_user

  def create
    @user = User.create user_params
    respond_with @user, status: :created
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

  def user_params
    params.require(:user).permit(
      :email, :login, :password, :facebook_token, :location, :description, :link, :name,
      :avatar_id, :avatar_content_type, :avatar_size, :avatar_filename,
      :profile_background_id, :profile_background_content_type, :profile_background_size, :profile_background_filename
    ).merge(password_confirmation: params[:user][:password])
  end
end
