# frozen_string_literal: true

class PhotosController < ApplicationController
  before_action :require_user
  before_action :find_attachable

  def create
    photo = @attachable.photos.create!(photo_params)
    render json: { id: photo.id }, status: :created
  end

  def destroy
    @attachable.photos.find(params[:id]).destroy
    head :ok
  end

  def reorder
    sorting = params.require(:sorting).map(&:to_i)
    @attachable.photos.each do |photo|
      photo.update_attribute :sorting, sorting.index(photo.id)
    end
    head :ok
  end

  private

  def find_attachable
    attachable_id = params["#{params[:attachable_class].model_name.param_key}_id"]
    @attachable = params[:attachable_class].includes(:photos).find_by!(user_id: current_user.id, id: attachable_id)
  end

  def photo_params
    params.require(:photo).permit(:image_id, :image_content_type, :image_size, :image_filename)
  end
end
