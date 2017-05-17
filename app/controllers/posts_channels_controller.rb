class PostsChannelsController < ApplicationController
  layout 'simple'

  def show
    channel = PostChannel.new(params[:id], user: current_user, page: params[:page], per: params[:per])
    @posts = channel.posts
  end
end
