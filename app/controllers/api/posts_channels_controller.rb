class Api::PostsChannelsController < ApiController
  def show
    @channel = PostChannel.find_by!(name: params[:id])
    @posts = PostChannel.get_posts(@channel, user: current_user, page: params[:page], per: params[:per])
    render json: @posts, include: %w[user]
  end
end
