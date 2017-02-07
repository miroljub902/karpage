class ProfilesController < ApplicationController
  layout 'simple', only: :index

  before_action :require_user, only: %i(follow unfollow)

  def index
    @users = if params[:search].present?
      @car_count = Car.has_photos.simple_search(params[:search]).count
      User.by_cars_owned.simple_search(params[:search]).page(params[:page]).per(8)
    else
      User.by_cars_owned.page(params[:page]).per(8)
    end
  end

  def show
    @user = User.find_by(login: params[:profile_id])
    return render_404 unless @user
    @user = @user.decorate
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
