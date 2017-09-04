# frozen_string_literal: true

class ProfileCarsController < ApplicationController
  layout 'simple', only: :index

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def index
    @filters = Filter.all
    @cars = Car.standard.has_photos.owner_has_login.includes(:user, :photos, :trim, model: :make)
    filter = Filter.find_by(id: params[:filter])
    if params[:search].present? || (params[:lat].present? && params[:lng].present?)
      @cars = @cars.simple_search(params[:search], params[:lat], params[:lng], params[:radius])
      @user_count = User.simple_search(params[:search], params[:lat], params[:lng]).count
    elsif filter
      @cars = filter.search
    end

    per_page = 12

    # Show random results on first page, order by date for page 2+
    if params[:page].to_i > 1 || params[:search].present? || (params[:lat].present? && params[:lng].present?)
      @cars = @cars.order(created_at: :desc)
      start_at = params[:page].to_i
      start_at = 1 if start_at.zero?
      @for_pagination = @cars.page(start_at).per(per_page)
      # Start at page 1 when user is at page 2 (since page 1 is really a random set)
      start_at -= 1 if params[:search].blank?
      @cars = @cars.page(start_at).per(per_page)
    else
      @for_pagination = @cars.page(params[:page]).per(per_page)
      @cars = @cars.where(id: @cars.pluck(:id).sample(per_page))
    end
  end

  def show
    user = User.find_by(login: params[:profile_id])
    car = begin
            user.cars.friendly.find(params[:car_id])
          rescue
            nil
          end
    return render_404 if user.nil? || car.nil?
    @car = UserCarDecorator.new(car)
    @car.increment! :hits unless @car.user_id == current_user.try(:id)
  end
end
