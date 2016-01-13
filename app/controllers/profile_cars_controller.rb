class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  def index
    @cars = Car.order(created_at: :desc).has_photos
    if params[:search].present?
      @cars = @cars.simple_search(params[:search])
      @user_count = User.simple_search(params[:search]).count
    end
    @cars = @cars.page(params[:page]).per(12)
  end

  def show
    user = User.find_by!(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find(params[:car_id]))
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
