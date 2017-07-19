class Api::MakesController < ApiController
  def index
    render json: Make.official.sorted.has_year(params[:year])
  end
end
