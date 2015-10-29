class ProfilesController < ApplicationController
  def show
    @user = User.find_by!(login: params[:profile_id]).decorate
    @cars = UserCarsDecorator.cars(@user)
  end
end
