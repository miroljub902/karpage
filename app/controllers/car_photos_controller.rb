class CarPhotosController < ApplicationController
  before_action :require_user

  def create
    car = current_user.cars.friendly.find(params[:car_id])
    photo = car.photos.create!(photo_params)
    render json: { id: photo.id }, status: :created
  end

  def destroy
    car = current_user.cars.friendly.find(params[:car_id])
    car.photos.find(params[:id]).destroy
    render nothing: true, status: :ok
  end

  private

  def photo_params
    params.require(:photo).permit(:image_id, :image_content_type, :image_size, :image_filename)
  end
end
