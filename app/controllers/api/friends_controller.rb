class Api::FriendsController < ApiController
  before_action :require_user

  def followers
    @users = current_user.followers.page(params[:page]).per(params[:per])
    render 'index'
  end

  def following
    @users = current_user.followees.page(params[:page]).per(params[:per])
    render 'index'
  end
end
