class UserSessionsController < ApplicationController
  before_action :require_no_user, only: %i(new create)
  before_action :require_user, only: :destroy
  after_action :track_signup, only: :create, if: -> { @user_session.valid? && @user_session.user.created_at > 10.seconds.ago }
  skip_before_action :require_complete_profile, only: :destroy

  layout 'simple'

  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html
      format.js { render '_modals/new', locals: { id: 'modalSignIn', content: 'new' } }
    end
  end

  def create
    @user_session = omniauth_session || normal_session
    user = @user_session.user
    respond_to do |format|
      format.js {
        # Double check with empty errors so we con't clear previously set errors
        if @user_session.errors.empty? && @user_session.valid?
          location = user.incomplete_profile? ? edit_user_path : profile_path(user)
          render inline: "window.location = '#{location}';"
        else
          render '_modals/new', locals: { id: 'modalSignIn', content: 'new' }
        end
      }
      format.html {
        # Double check with empty errors so we con't clear previously set errors
        if @user_session.errors.empty? && @user_session.valid?
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

  def track_signup
    GATracker.event! @user_session.user, category: 'user', action: 'signup', label: 'website', value: 1
  end

  def omniauth_session
    return nil unless env['omniauth.auth']
    identity = Identity.from_omniauth(env['omniauth.auth'])
    UserSession.create(identity.user, true)
  rescue ActiveRecord::StatementInvalid
    UserSession.new.tap do |session|
      session.errors.add :base, 'An unexpected error occurred. Please try again later.'
    end
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
