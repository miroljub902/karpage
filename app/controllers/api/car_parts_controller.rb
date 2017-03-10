class Api::CarPartsController < ApiController
  before_action :require_user
  before_action :find_car

  def create
    @car_part = @car.parts.create(car_part_params)
    respond_with @car_part, location: nil, status: :created
  end

  def update
    @car_part = @car.parts.find(params[:id])
    @car_part.update_attributes car_part_params
    respond_with @car_part
  end

  def destroy
    @car_part = @car.parts.find(params[:id])
    @car_part.destroy
    respond_with @car_part
  end

  private

  def car_part_params
    params.require(:car_part).permit(
      :type, :manufacturer, :model, :price, :review, :sorting,
      photo_attributes: %i(id _destroy image_id image_content_type image_size image_filename)
    )
  end

  def find_car
    @car = current_user.cars.find(params[:car_id])
  end
end
