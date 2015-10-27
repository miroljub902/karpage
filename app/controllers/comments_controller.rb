class CommentsController < ApplicationController
  def create
    @comment = current_user.comments.create(comment_params.merge(commentable: commentable))
    redirect_to return_to_path
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def return_to_path
    params[:return_to].presence || commentable
  end

  def commentable
    if commentable_class.respond_to?(:friendly)
      commentable_class.friendly.find(commentable_id)
    else
      commentable_class.find(commentable_id)
    end
  end

  def commentable_id
    params["#{params[:scope]}_id"]
  end

  def commentable_class
    @_class ||= params[:scope].to_s.classify.constantize
  end
end
