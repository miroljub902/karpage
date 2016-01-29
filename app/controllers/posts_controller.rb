class PostsController < ApplicationController
  respond_to :html, :js

  layout 'simple', only: %i(new create edit update)

  before_action :require_user, only: %i(new create edit update destroy)
  before_action :find_user

  def index
    @posts = @user.posts_for_feed
    @post = @user.posts.new
    reset_new_stuff @posts, owner: nil
  end

  def show
    @post = @user.posts.find(params[:id]).decorate
    @post.increment! :views unless current_user && current_user.id == @user.id
  end

  def create
    @post = @user.posts.new(post_params)
    if @post.save
      redirect_to posts_path(@user)
    else
      flash.now.alert = @post.errors.full_messages.to_sentence
      render :edit
    end
  end

  def edit
    @post = @user.posts.find(params[:id]).decorate
  end

  def update
    @post = @user.posts.find(params[:id]).decorate
    if @post.update_attributes(post_params)
      redirect_to posts_path(@user)
    else
      flash.now.alert = @post.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @post = @user.posts.find(params[:id])
    @post.destroy
    redirect_to posts_path(@user)
  end

  private

  def post_params
    params.require(:post).permit(:body, :photo)
  end

  def find_user
    @user = if params[:profile_id]
      User.find_by!(login: params[:profile_id]).decorate
    else
      current_user
    end
  end
end
