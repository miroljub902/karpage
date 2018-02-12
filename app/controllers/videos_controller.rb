# frozen_string_literal: true

class VideosController < ApplicationController
  before_action :require_user
  before_action :find_attachable

  def create
    operation = Video::UploadSingle.(@attachable, video_params)
    render json: { id: operation.video.id }, status: :created
  end

  def destroy
    @attachable.videos.find(params[:id]).destroy
    head :ok
  end

  private

  def find_attachable
    attachable_id = params["#{params[:attachable_class].model_name.param_key}_id"]
    @attachable = params[:attachable_class].includes(:video).find_by!(user_id: current_user.id, id: attachable_id)
  end

  def video_params
    params.require(:video).permit(:source_id, :source_filename)
  end
end
