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
    @user_session = omniauth_session || normal_session
    @user_session.valid? ? redirect_to(user_path) : render(:new)
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default root_path, notice: 'Goodbye!'
  end

  private

  def omniauth_session
    return nil unless env['omniauth.auth']
    identity = Identity.from_omniauth(env['omniauth.auth'])
    UserSession.create(identity.user, true)
  end

  def normal_session
    UserSession.new(session_params.merge(remember_me: true)).tap do |session|
      flash_errors_with_save session
    end
  end

  def session_params
    params.require(:user_session).permit(:login, :password)
  end
end
