class Api::CarsController < ApiController
  before_action :require_user, only: %i(create update destroy reset_counter)

  def index
    @cars = Car.has_photos.owner_has_login.includes(:model, :make).not_blocked(current_user)
    if params[:search].present?
      @cars = @cars.simple_search(params[:search])
      @user_count = User.simple_search(params[:search]).count
    elsif params[:filter_id]
      @cars = Filter.find(params[:filter_id]).search
    end

    per = params[:per] ? params[:per].to_i : Car.default_per_page

    if params[:page].to_i > 1 || params[:search].present?
      start_at = params[:page].to_i
      start_at = 1 if start_at == 0
      start_at -= 1 unless params[:search].present? # Start at page 1 when user is at page 2 (since page 1 is really a random set)
      @cars = @cars.distinct.order(created_at: :desc).page(start_at).per(per)
      @total_count = @cars.total_count
    else
      @total_count = @cars.count
      @cars = @cars.where(id: @cars.pluck(:id).sample(per))
    end

    respond_with @cars
  end

  def show
    @car = Car.not_blocked(current_user).find(params[:id])
    respond_with @car
  end

  COUNTERS = {
    'car_likes' => -> (car) { NewStuff.reset_count(car.likes, car.user, owner: car.user) },
    'car_comments' => -> (car) { NewStuff.reset_count(car.comments, car.user, owner: car.user) }
  }

  def reset_counter
    return render(nothing: true, status: :not_found) unless COUNTERS.has_key?(params[:counter])
    car = current_user.cars.find(params[:id])
    COUNTERS[params[:counter]].call car
    render nothing: true, status: :ok
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
      photos_attributes: %i(id _destroy image_id image_content_type image_size image_filename sorting)
    )
  end
end
