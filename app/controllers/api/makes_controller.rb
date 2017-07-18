class Api::MakesController < ApiController
  def index
    render json: Make.official.sorted
  end
end
