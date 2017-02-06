class FollowsController < ApplicationController
  before_action :find_user

  def index
    @users = if params[:followers]
      reset_new_stuff @user.follows_by, owner: @user
      @user.followers.order('follows.created_at DESC')
    else
      @user.followees.order('follows.created_at DESC')
    end.decorate
  end

  private

  def find_user
    @user = User.find_by(login: params[:profile_id])
    return render_404 unless @user
    @user = @user.decorate
  end
end
