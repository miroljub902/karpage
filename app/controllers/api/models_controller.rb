# frozen_string_literal: true

class Api::ModelsController < ApiController
  def index
    render json: Model.with_make_id(params[:make_id]).official.has_year(params[:year]).sorted
  end
end
