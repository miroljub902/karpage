class Api::BlocksController < ApiController
  before_action :require_user

  def create
    @user = User.find(params[:profile_id])
    @block = current_user.blocks.create(blocked_user: @user)
    render nothing: true, status: :created
  end
end
