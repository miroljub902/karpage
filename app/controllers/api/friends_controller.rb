# frozen_string_literal: true

class Api::FriendsController < ApiController
  before_action :find_user

  def followers
    @users = @user.followers.order('follows.created_at DESC').page(params[:page]).per(params[:per])
    @users = @users.simple_search(params[:search]) if params[:search].present?
    render 'index'
  end

  def following
    @users = @user.followees.order('follows.created_at DESC').page(params[:page]).per(params[:per])
    @users = @users.simple_search(params[:search]) if params[:search].present?
    render 'index'
  end

  private

  def find_user
    @user = User.find(params[:profile_id])
  end
end
