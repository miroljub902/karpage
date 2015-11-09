class ProfilesController < ApplicationController
  layout 'simple', only: :index

  def index
    @users = if params[:search].present?
      User.search(params[:search]).page(params[:page]).per(8)
    else
      []
    end
  end

  def show
    @user = User.find_by!(login: params[:profile_id]).decorate
    @cars = UserCarsDecorator.cars(@user)
  end
end
