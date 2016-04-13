class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  def index
    @filters = Filter.all
    @cars = Car.has_photos
    filter = Filter.find_by(id: params[:filter])
    if params[:search].present?
      @cars = @cars.simple_search(params[:search])
      @user_count = User.simple_search(params[:search]).count
    elsif filter
      @cars = filter.search
    end

    # Show random results on first page, order by date for page 2+
    if params[:page].to_i > 1 || params[:search].present?
      @cars = @cars.order(created_at: :desc)
      start_at = params[:page].to_i
      start_at = 1 if start_at == 0
      start_at -= 1 unless params[:search].present? # Start at page 1 when user is at page 2 (since page 1 is really a random set)
      @cars = @cars.page(start_at).per(12)
    else
      @for_pagination = @cars.page(params[:page]).per(12)
      @cars = @cars.where(id: @cars.pluck(:id).sample(12))
    end
  end

  def show
    user = User.find_by!(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find(params[:car_id]))
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
