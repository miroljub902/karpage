class UserSessionsController < ApplicationController
  before_filter :require_no_user, only: %i(new create)
  before_filter :require_user, only: :destroy

  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalSignIn', content: 'new' } }
    end
  end

  def create
    @user_session = omniauth_session || normal_session
    respond_to do |format|
      format.js {
        if @user_session.valid?
          render inline: 'window.location.reload();'
        else
          render '_modals/new', locals: { id: 'modalSignIn', content: 'new' }
        end
      }
    end
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
