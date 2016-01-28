class FollowsController < ApplicationController
  def index
    @user = User.find_by(login: params[:profile_id]).decorate
    @users = if params[:followers]
      reset_new_stuff @user.follows_by, owner: @user
      @user.followers
    else
      @user.followees
    end.decorate
  end
end
