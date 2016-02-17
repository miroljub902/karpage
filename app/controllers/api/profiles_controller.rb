class Api::ProfilesController < ApiController
  def index
    @users = if params[:search].present?
               User.by_cars_owned.simple_search(params[:search]).page(params[:page])
             else
               User.by_cars_owned.page(params[:page])
             end
    respond_with @users
  end

  def show
    @user = User.includes(:dream_cars, :next_car, cars: %i(make model)).find_by(login: params[:id])
    @cars = UserCarsDecorator.cars(@user)
    respond_with @user
  end
end
