class Api::PostsChannelsController < ApiController
  def index
    @channels = PostChannel.all
    respond_with @channels
  end

  def show
    @channel = PostChannel.find_by!(name: params[:id])
    @posts = PostChannel.get_posts(@channel, user: current_user, page: params[:page], per: params[:per])
    respond_with @posts, include: %w[user]
  end
end
