class Api::CommentsController < ApiController
  before_action :require_user, only: %i(create update destroy)
  before_action :find_commentable

  def index
    @comments = @commentable.comments.not_blocked(current_user).sorted.page(params[:page])
    respond_with :api, @comments
  end

  def create
    @comment = current_user.comments.create comment_params.merge(commentable: @commentable)
    respond_with :api, @comment, status: :created
  end

  def update
    @comment = @commentable.comments.find_by!(id: params[:id], user_id: current_user.id)
    @comment.update_attributes comment_params
    respond_with :api, @comment
  end

  def destroy
    @comment = @commentable.comments.find_by!(id: params[:id], user_id: current_user.id)
    @comment.destroy
    render nothing: true, status: :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_commentable
    klass = params[:commentable_type].constantize
    @commentable = klass.find params["#{klass.model_name.param_key}_id"]
  end
end
