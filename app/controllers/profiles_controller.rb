class ProfilesController < ApplicationController
  layout 'simple', only: :index

  before_action :require_user, only: %i(follow unfollow)

  def index
    @users = if params[:search].present?
      User.search(params[:search]).page(params[:page]).per(8)
    else
      []
    end
  end

  def show
    @user = User.find_by!(login: params[:profile_id]).decorate
    @cars = UserCarsDecorator.cars(@user)
  end

  def follow
    @user = User.find_by!(login: params[:profile_id])
    current_user.follow! @user
    redirect_to profile_path(@user)
  end

  def unfollow
    @user = User.find_by!(login: params[:profile_id])
    current_user.unfollow! @user
    redirect_to profile_path(@user)
  end
end
