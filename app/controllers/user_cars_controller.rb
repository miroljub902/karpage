class UserCarsController < ApplicationController
  before_action :require_user

  def new
    @car = current_user.cars.new(new_car_params)
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

  def edit
    @car = current_user.cars.friendly.find(params[:id])
    render '_modals/new', locals: { id: 'modalNewCar', content: 'edit', options: { car: @car }}
  end

  def update
    @car = current_user.cars.friendly.find(params[:id])
    if @car.update_attributes(car_params)
      render inline: 'window.location.reload()'
    else
      render '_modals/new', locals: { id: 'modalEditCar', content: 'edit', options: { car: @car }}
    end
  end

  def destroy
    @car = current_user.cars.friendly.find(params[:id])
    @car.destroy
    render inline: 'window.location.reload()'
  end

  private

  def new_car_params
    params.permit!.slice(:past, :current, :first).merge(current: params[:current] == 'true')
  end

  def car_params
    params.require(:car).permit(:year, :make_name, :car_model_name, :description, :first, :current, :past)
  end
end
