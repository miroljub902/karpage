class PostsChannelsController < ApplicationController
  layout 'simple'

  def show
    @channel = PostChannel.active.find_by!(name: params[:id])
    @posts = PostChannel.get_posts(@channel, user: current_user, page: params[:page], per: params[:per])
  end
end
