class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  def index
    @cars = Car.popular
    @cars = @cars.search(params[:search]) if params[:search].present?
    @cars = @cars.page(params[:page]).per(8)
  end

  def show
    user = User.find_by(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find(params[:car_id]))
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
