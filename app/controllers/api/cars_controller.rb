class Api::CarsController < ApiController
  before_action :require_user, only: %i(create update destroy)

  def index
    @cars = Car.order(created_at: :desc).includes(:model, :make).has_photos
    @cars = @cars.simple_search(params[:search]) if params[:search].present?
    @cars = @cars.page(params[:page]).per(12)
    respond_with @cars
  end

  def show
    @car = Car.find(params[:id])
    respond_with @car
  end

  def create
    @car = current_user.cars.create(car_params)
    respond_with :api, @car, status: :created
  end

  def update
    @car = current_user.cars.find(params[:id])
    @car.update_attributes car_params
    respond_with @car
  end

  def destroy
    @car = current_user.cars.find(params[:id])
    @car.destroy
    respond_with @car
  end

  private

  def car_params
    params.require(:car).permit(
      :year,
      :make_name,
      :car_model_name,
      :description,
      :first,
      :current,
      :past,
      photos_attributes: %i(image_id image_content_type image_size image_filename sorting)
    )
  end
end
