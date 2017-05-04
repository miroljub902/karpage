class Api::SessionsController < ApiController
  before_action :require_user, only: :destroy

  def create
    @session = facebook_session || UserSession.create(session_params)
    @session.user.update_attribute :device_info, session_params[:device_info] if session_params.key?(:device_info)
    respond_with @session, status: :created
  end

  def destroy
    @session = current_session
    current_user.update_attribute :device_info, nil
    @session.destroy
    head :ok
  end

  private

  def facebook_session
    UserSession.from_facebook(session_params[:facebook_token]) if session_params[:facebook_token]
  end

  def session_params
    params.require(:session).permit(:login, :password, :facebook_token, device_info: %i(user_id))
  end
end
