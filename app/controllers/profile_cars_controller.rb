class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  def index
    @filters = Filter.all
    @cars = Car.has_photos.owner_has_login
    filter = Filter.find_by(id: params[:filter])
    if params[:search].present?
      @cars = @cars.simple_search(params[:search])
      @user_count = User.simple_search(params[:search]).count
    elsif filter
      @cars = filter.search
    end

    per_page = 12

    # Show random results on first page, order by date for page 2+
    if params[:page].to_i > 1 || params[:search].present?
      @cars = @cars.order(created_at: :desc)
      start_at = params[:page].to_i
      start_at = 1 if start_at == 0
      @for_pagination = @cars.page(start_at).per(per_page)
      start_at -= 1 unless params[:search].present? # Start at page 1 when user is at page 2 (since page 1 is really a random set)
      @cars = @cars.page(start_at).per(per_page)
    else
      @for_pagination = @cars.page(params[:page]).per(per_page)
      @cars = @cars.where(id: @cars.pluck(:id).sample(per_page))
    end
  end

  def show
    user = User.find_by(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find_by(id: params[:car_id])) if user
    return render_404 if user.nil? || @car.nil?
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
