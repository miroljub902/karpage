class Api::ProfilesController < ApiController
  before_action :require_user, except: %i(index show)

  def index
    @users = if params[:search].present?
               User.by_cars_owned.simple_search(params[:search]).page(params[:page])
             else
               User.by_cars_owned.page(params[:page])
             end
    @users = @users.not_blocked(current_user).per(params[:per] || User.default_per_page)
    respond_with @users
  end

  def show
    @user = User.includes(:dream_cars, :next_car, cars: %i(make model)).not_blocked(current_user).find_by(login: params[:id])
    @cars = UserCarsDecorator.cars(@user)
    respond_with @user
  end

  def follow
    @user = User.find_by!(login: params[:id])
    current_user.follow! @user
    render nothing: true, status: :created
  end

  def unfollow
    @user = User.find_by!(login: params[:id])
    current_user.unfollow! @user
    render nothing: true, status: :ok
  end
end
