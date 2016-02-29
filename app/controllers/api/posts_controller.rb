class Api::PostsController < ApiController
  before_action :require_user, only: %i(create update destroy feed)

  def index
    scope = params[:user_id] ? Post.where(user_id: params[:user_id]) : Post
    @posts = scope.sorted.page(params[:page])
    respond_with @posts
  end

  def feed
    @posts = current_user.decorate.friends_posts_for_feed.sorted.page(params[:page]).decorate
    respond_with @posts
  end

  def show
    @post = Post.find(params[:id])
    respond_with @post
  end

  def create
    @post = current_user.posts.create(post_params)
    respond_with :api, @post, status: :created
  end

  def update
    @post = current_user.posts.find(params[:id])
    @post.update_attributes post_params
    respond_with @post
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    respond_with @post
  end

  private

  def post_params
    params.require(:post).permit(:body, :photo_id, :photo_content_type, :photo_size, :photo_filename)
  end
end