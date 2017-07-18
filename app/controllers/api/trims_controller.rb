class Api::TrimsController < ApiController
  def index
    render json: Trim.with_make_id(params[:make_id]).with_model_id(params[:model_id]).official.sorted
  end
end
