# frozen_string_literal: true

class PostsController < ApplicationController
  respond_to :html, :js

  layout 'simple', only: %i[new create edit update explore]

  before_action :require_user, only: %i[new create edit update destroy]
  before_action :find_user

  def index
    @posts = filter_posts.page(params[:page])
    @post = @user.posts.new
    reset_new_stuff @posts, owner: nil
  end

  def explore
    @posts = filter_posts.page(params[:page])
  end

  def show
    @post = @user.posts.find_by(id: params[:id])
    return render_404 unless @post
    @post = @post.decorate
    @post.increment! :views unless current_user && current_user.id == @user.id
    respond_to do |format|
      format.html
      format.json { render 'viewer' }
    end
  end

  def create
    @post = @user.posts.new(post_params)
    if @post.save
      redirect_to params[:return_to] || posts_path(@user)
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

  def filter_posts
    scope = params[:following] && signed_in? ? 'friends' : params[:scope]
    case scope
    when 'all'
      Post.all
    when 'friends'
      current_user.friends_posts_for_feed
    when nil
      Post.all
    else
      @user = User.find_by!(login: params[:scope])
      @user.posts
    end.sorted.with_photo.global
  end

  def post_params
    params.require(:post).permit(:body, :photo, :post_channel_id)
  end

  def find_user
    @user = if params[:profile_id]
              user = User.find_by(login: params[:profile_id])
              return render_404 unless user
              user.decorate
            else
              current_user
            end
  end
end
