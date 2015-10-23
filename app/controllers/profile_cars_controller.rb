class ProfileCarsController < ApplicationController
  def show
    user = User.find_by(login: params[:profile_id])
    @car = user.cars.friendly.find(params[:car_id])
  end
end
