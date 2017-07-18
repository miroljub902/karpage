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
    render '_modals/new', locals: { id: 'modalEditCar', content: 'edit', options: { car: @car }}
  end

  def update
    @car = current_user.cars.friendly.find(params[:id])
    if @car.update_attributes(car_params)
      render inline: 'window.location.reload()'
    else
      render '_modals/new', locals: { id: 'modalEditCar', content: 'edit', options: { car: @car }}
    end
  end

  def resort
    ids = params[:ids].split(',').map(&:to_i)
    current_user.cars.find(ids).each do |car|
      car.update_column :sorting, ids.index(car.id)
    end

    respond_to do |format|
      format.js { render nothing: true, status: :ok }
    end
  end

  def destroy
    @car = current_user.cars.friendly.find(params[:id])
    @car.destroy
    render inline: 'window.location.reload()'
  end

  private

  def new_car_params
    params.permit!.slice(:type)
  end

  def car_params
    params.require(:car).permit(
      :year,
      :model_id,
      :trim_id,
      :description,
      :type,
      photos_attributes: %i(image_id image_content_type image_size image_filename sorting)
    )
  end
end
