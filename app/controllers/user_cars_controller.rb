class UserCarsController < ApplicationController
  before_action :require_user

  def new
    @car = current_user.cars.new
    render '_modals/new', locals: { id: 'modalNewCar', content: 'new', options: { car: @car }}
  end

  def create
    @car = current_user.cars.new(car_params)
    if @car.save
      render inline: 'window.location.reload()'
    else
      render '_modals/new', locals: { id: 'modalNewCar', content: 'new', options: { car: @car }}
    end
  end

  private

  def car_params
    params.require(:car).permit(:year, :make_name, :car_model_name, :description).merge(params.slice(:first, :current, :past))
  end
end
