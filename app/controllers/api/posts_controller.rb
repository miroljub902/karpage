class Api::PostsController < ApiController
  before_action :require_user, only: %i(create update destroy)

  def index
    @posts = Post.page(params[:page]).per(12)
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
    params.require(:post).permit(:body, :photo)
  end
end
