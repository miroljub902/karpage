# frozen_string_literal: true

class UpvotesController < ApplicationController
  before_action :require_user
  before_action :find_voteable

  def toggle
    @upvote = Upvote.toggle! @voteable, current_user
    @voteable.reload
    respond_to do |format|
      format.html do
        redirect_back_or_default post_path(@voteable.user, @voteable)
      end
      format.js
    end
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
