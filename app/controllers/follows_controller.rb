class FollowsController < ApplicationController
  def index
    @user = User.find_by(login: params[:profile_id]).decorate
    @users = if params[:followers]
      reset_new_stuff @user.follows_by, owner: @user
      @user.followers.order('follows.created_at DESC')
    else
      @user.followees.order('follows.created_at DESC')
    end.decorate
  end
end
