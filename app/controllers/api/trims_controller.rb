# frozen_string_literal: true

class Api::TrimsController < ApiController
  def index
    render json: Trim.with_make_id(params[:make_id])
                     .with_model_id(params[:model_id])
      .official
                     .with_year(params[:year])
                     .sorted
  end
end
