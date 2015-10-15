class UserSessionsController < ApplicationController
  respond_to :html, :js

  layout 'blank'

  before_filter :require_no_user, only: %i(new create)
  before_filter :require_user, only: :destroy

  def new
    @user_session = UserSession.new
    respond_with @user_session
  end

  def create
    @user_session = UserSession.new(session_params.merge(remember_me: true))
    flash_errors_with_save @user_session
    respond_with @user_session, location: root_path
  end

  def destroy
    current_user_session.destroy
    redirect_to root_path, notice: 'Goodbye!'
  end

  private

  def session_params
    params.require(:user_session).permit(:login, :password)
  end
end
