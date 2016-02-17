class Api::LikesController < ApiController
  before_action :require_user, :find_likeable

  def create
    Like.like! @likeable, current_user
    render nothing: true, status: :created
  end

  def destroy
    Like.unlike! @likeable, current_user
    render nothing: true, status: :ok
  end

  def find_likeable
    klass = params[:likeable_type].constantize
    @likeable = klass.find params["#{klass.model_name.param_key}_id"]
  end
end
