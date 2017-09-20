# frozen_string_literal: true

class Api::CarsController < ApiController
  before_action :require_user, only: %i[create update destroy reset_counter]

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def index
    @cars = Car.standard
               .has_photos
               .owner_has_login
               .includes(:user, :model, :make, parts: :photo)
               .not_blocked(current_user)

    if params[:search].present?
      @cars = @cars.simple_search(params[:search], params[:lat], params[:lng], params[:radius])
    elsif params[:filter_id]
      @cars = Filter.find(params[:filter_id]).search
    end

    per = params[:per] ? params[:per].to_i : Car.default_per_page

    if params[:page].to_i > 1 || params[:search].present? || (params[:lat].present? && params[:lng].present?)
      start_at = params[:page].to_i
      start_at = 1 if start_at.zero?
      # Start at page 1 when user is at page 2 (since page 1 is really a random set)
      start_at -= 1 if params[:search].blank?
      @cars = @cars.distinct.order(created_at: :desc).page(start_at).per(per)
      @total_count = @cars.total_count
    else
      @total_count = @cars.count
      @cars = @cars.where(id: @cars.pluck(:id).sample(per))
    end

    respond_with @cars
  end

  def show
    @car = Car.not_blocked(current_user).includes(:user, parts: :photo).find(params[:id])
    respond_with @car
  end

  COUNTERS = {
    'car_likes' => ->(car) { NewStuff.reset_count(car.likes, car.user, owner: car.user) },
    'car_comments' => ->(car) { NewStuff.reset_count(car.comments, car.user, owner: car.user) }
  }.freeze

  def reset_counter
    return render(nothing: true, status: :not_found) unless COUNTERS.key?(params[:counter])
    car = current_user.cars.find(params[:id])
    COUNTERS[params[:counter]].call car
    head :ok
  end

  def create
    @car = Car::Save.new(car_params.merge(user: current_user))
    @car.save
    respond_with :api, @car, status: :created
  end

  def update
    @car = Car::Save.where(user: current_user).find(params[:id])
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
    params = self.params.require(:car).permit(
      :year,
      :model_id,
      :trim_id,
      :description,
      :sorting,
      :type,
      :make_name,
      :car_model_name,
      :trim_name,
      photos_attributes: %i[id _destroy image_id image_content_type image_size image_filename sorting],
      parts_attributes: [
        :type, :manufacturer, :model, :price,
        { photo_attributes: %i[id _destroy image_id image_content_type image_size image_filename] }
      ]
    )
    params[:type] = case params[:type]
                    when 'first'
                      Car.types[:first_car]
                    when 'current', 'current_cars'
                      Car.types[:current_car]
                    when 'previous'
                      Car.types[:past_car]
                    else
                      params[:type]
                    end
    params
  end
end
