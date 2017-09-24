# frozen_string_literal: true

class CarPhotosController < PhotosController
  private

  def find_attachable
    @attachable = current_user.cars.friendly.find(params[:car_id])
  end
end
