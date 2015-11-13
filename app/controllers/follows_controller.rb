class FollowsController < ApplicationController
  def index
    @user = User.find_by(login: params[:profile_id]).decorate
    @users = if params[:followers]
      @user.followers
    else
      @user.followees
    end.decorate
  end
end
