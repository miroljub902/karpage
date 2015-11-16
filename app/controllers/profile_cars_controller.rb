class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  def index
    @cars = Car.popular
    if params[:search].present?
      @cars = @cars.search(params[:search])
      @user_count = User.search(params[:search]).count
    end
    @cars = @cars.page(params[:page]).per(8)
  end

  def show
    user = User.find_by(login: params[:profile_id])
    @car = UserCarDecorator.new(user.cars.friendly.find(params[:car_id]))
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
