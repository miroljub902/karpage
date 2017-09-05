# frozen_string_literal: true

class Api::ProfilesController < ApiController
  before_action :require_user, except: %i[index show]

  # rubocop:disable Metrics/AbcSize
  def index
    scope = User.by_cars_owned.cars_count.not_blocked(current_user).page(params[:page])
    @users = if params[:search].present?
               scope.simple_search(params[:search], params[:lat], params[:lng], params[:radius])
             else
               scope
             end
    @users = @users.distinct.per(params[:per] || User.default_per_page)
    respond_with @users
  end

  def show
    @user = User.includes(:dream_cars, cars: %i[make model]).not_blocked(current_user)
    @user = @user.find_by(login: params[:id]) || @user.find(params[:id])
    @cars = UserCarsDecorator.cars(@user)
    respond_with @user
  end

  def follow
    @user = User.find_by(login: params[:id]) || User.find(params[:id])
    current_user.follow! @user
    render nothing: true, status: :created
  end

  def unfollow
    @user = User.find_by(login: params[:id]) || User.find(params[:id])
    current_user.unfollow! @user
    render nothing: true, status: :ok
  end
end
