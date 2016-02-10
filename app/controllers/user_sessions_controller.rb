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
    user = @user_session.user
    respond_to do |format|
      format.js {
        if @user_session.valid?
          location = user.incomplete_profile? ? edit_user_path : profile_path(user)
          render inline: "window.location = '#{location}';"
        else
          render '_modals/new', locals: { id: 'modalSignIn', content: 'new' }
        end
      }
      format.html {
        if @user_session.valid?
          location = user.incomplete_profile? ? edit_user_path : profile_path(user)
          redirect_to location, notice: nil
        else
          render :new
        end
      }
    end
  end

  def destroy
    current_user_session.destroy
    respond_to do |format|
      format.html do
        redirect_to root_path
      end
      format.json
    end
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
