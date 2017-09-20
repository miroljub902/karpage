# frozen_string_literal: true

class Api::LikesController < ApiController
  before_action :require_user, :find_likeable

  def create
    Like.like! @likeable, current_user
    head :created
  end

  def destroy
    Like.unlike! @likeable, current_user
    head :ok
  end

  private

  def find_likeable
    klass = params[:likeable_type].constantize
    @likeable = klass.find params["#{klass.model_name.param_key}_id"]
  end
end
