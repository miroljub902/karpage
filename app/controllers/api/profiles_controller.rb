class Api::ProfilesController < ApiController
  def show
    @user = User.includes(:dream_cars, :next_car, cars: %i(make model)).find_by(login: params[:id])
    @cars = UserCarsDecorator.cars(@user)
    respond_with @user
  end
end
