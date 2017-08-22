# frozen_string_literal: true

class Api::FriendsController < ApiController
  before_action :find_user

  def followers
    @users = @user.followers.order('follows.created_at DESC').page(params[:page]).per(params[:per])
    render 'index'
  end

  def following
    @users = @user.followees.order('follows.created_at DESC').page(params[:page]).per(params[:per])
    render 'index'
  end

  private

  def find_user
    @user = User.find(params[:profile_id])
  end
end
