class Api::SessionsController < ApiController
  before_action :require_user, only: :destroy

  def create
    @session = facebook_session || UserSession.create(session_params)
    respond_with @session, status: :created
  end

  def destroy
    @session = current_session
    @session.destroy
    head :ok
  end

  private

  def facebook_session
    UserSession.from_facebook(session_params[:facebook_token]) if session_params[:facebook_token]
  end

  def session_params
    params.require(:session).permit(:login, :password, :facebook_token)
  end
end
