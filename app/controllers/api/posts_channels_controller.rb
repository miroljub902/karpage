# frozen_string_literal: true

class Api::PostsChannelsController < ApiController
  def index
    @channels = PostChannel.active.sorted
    respond_with @channels
  end

  def show
    @channel = PostChannel.active.find_by!(name: params[:id])
    @posts = PostChannel.get_posts(@channel, user: current_user, page: params[:page], per: params[:per])
    respond_with @posts, include: %w[user]
  end
end
