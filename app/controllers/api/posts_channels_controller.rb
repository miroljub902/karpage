class Api::PostsChannelsController < ApiController
  def show
    channel = PostChannel.new(params[:id], user: current_user, page: params[:page], per: params[:per])
    render json: channel.posts, include: %w[user]
  end
end
