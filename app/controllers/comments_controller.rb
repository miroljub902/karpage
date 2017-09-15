# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :require_user

  def create
    @comment = current_user.comments.create(comment_params.merge(commentable: commentable))
    respond_to do |format|
      format.html { redirect_to return_to_path }
      format.js
    end
  end

  def destroy
    @comment = commentable.comments.find_by(id: params[:id])
    return render_404 unless @comment
    authorize @comment
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to params[:return_to].presence || root_path }
      format.js
    end
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
