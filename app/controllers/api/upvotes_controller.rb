# frozen_string_literal: true

class Api::UpvotesController < ApiController
  before_action :require_user
  before_action :find_voteable

  def create
    Upvote.vote! @voteable, current_user
    render json: @voteable.reload, status: :created, include: []
  end

  def destroy
    Upvote.unvote! @voteable, current_user
    render json: @voteable, include: []
  end

  private

  def find_voteable
    klass = params[:voteable_type].constantize
    @voteable = klass
                .select_all
                .select_upvoted(current_user)
                .select_liked(current_user)
                .find(params["#{klass.model_name.param_key}_id"])
  end
end
