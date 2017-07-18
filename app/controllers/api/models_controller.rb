class Api::ModelsController < ApiController
  def index
    render json: Model.with_make_id(params[:make_id]).official.sorted
  end
end
