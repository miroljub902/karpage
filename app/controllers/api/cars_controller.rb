class Api::CarsController < ApiController
  def index
    @cars = Car.order(created_at: :desc).includes(:model, :make).has_photos
    @cars = @cars.simple_search(params[:search]) if params[:search].present?
    @cars = @cars.page(params[:page]).per(12)
    respond_with @cars
  end
end
