# frozen_string_literal: true

class Api::PostsController < ApiController
  before_action :require_user, only: %i[create update destroy feed]

  # rubocop:disable Metrics/AbcSize
  def index
    scope = params[:user_id] ? Post.where(user_id: params[:user_id]) : Post
    @posts = scope
             .with_photo_or_video
             .sorted
             .global
             .not_blocked(current_user)
             .includes(:sorted_photos, :user)
             .page(params[:page]).per(params[:per] || Post.default_per_page)
    respond_with @posts, include: %w[user comments.user photos]
  end

  def feed
    @posts = current_user
             .decorate
             .friends_posts_for_feed
             .with_photo_or_video
             .sorted
             .includes(:sorted_photos, :user)
             .page(params[:page])
             .per(params[:per] || Post.default_per_page)
    respond_with @posts, include: %w[user comments.user photos]
  end

  def show
    @post = Post.not_blocked(current_user).includes(:sorted_photos, :user).find_by(id: params[:id])
    return render_404 unless @post
    respond_with @post, include: %w[user comments.user photos]
  end

  def create
    @post = current_user.posts.create(post_params)
    respond_with :api, @post, status: :created, include: []
  end

  def update
    @post = current_user.posts.includes(:sorted_photos, :user).find(params[:id])
    @post.update_attributes post_params
    respond_with @post, include: []
  end

  def destroy
    @post = current_user.posts.includes(:sorted_photos, :user).find(params[:id])
    @post.destroy
    respond_with @post, include: []
  end

  private

  def post_params
    params.require(:post).permit(
      :body, :photo_id, :photo_content_type, :photo_size, :photo_filename, :post_channel_id, :post_channel_name,
      photos_attributes: %i[id _destroy image_id image_content_type image_size image_filename sorting]
    )
  end
end
