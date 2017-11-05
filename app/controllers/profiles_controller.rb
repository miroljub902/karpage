# frozen_string_literal: true

class ProfilesController < ApplicationController
  layout 'simple', only: :index

  before_action :require_user, only: %i[follow unfollow]
  before_action -> { sanitize_string_params :page, :search, :lat, :lng, :radius }

  # rubocop:disable Metrics/AbcSize
  def index
    user_scope = User.not_blocked(current_user)
    @users = if params[:search].present? || (params[:lat].present? && params[:lng].present?)
               @car_count = Car.has_photos.simple_search(
                 params[:search], params[:lat], params[:lng], params[:radius]
               ).count
               search_scope = user_scope.simple_search(params[:search], params[:lat], params[:lng], params[:radius])
               @user_count = search_scope.count
               search_scope.cars_count
             else
               @user_count = user_scope.count
               User.cars_count
             end

    @users = params[:friends_first] && current_user ? @users.friends_first(current_user) : @users.by_cars_owned
    @users = @users.page(params[:page]).per(8)

    respond_to do |format|
      format.html
      format.json do
        render json: @users, each_serializer: Api::UserSerializer
      end
    end
  end

  def show
    @user = User.find_by(login: params[:profile_id])
    return render_404 unless @user
    @user = @user.decorate
    @cars = UserCarsDecorator.cars(@user)
  end

  def follow
    @user = User.find_by!(login: params[:profile_id])
    current_user.follow! @user
    redirect_to profile_path(@user)
  end

  def unfollow
    @user = User.find_by!(login: params[:profile_id])
    current_user.unfollow! @user
    redirect_to profile_path(@user)
  end
end
