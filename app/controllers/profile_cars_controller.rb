class ProfileCarsController < ApplicationController
  def show
    user = User.find_by(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find(params[:car_id]))
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
