class PasswordResetsController < ApplicationController
  before_action :require_no_user

  layout 'simple'

  def new
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalPasswordReset', content: 'new' } }
    end
  end

  def create
    @user = User.find_by_login_or_email(params[:login])
    @user.deliver_reset_password_instructions! if @user

    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalPasswordReset', content: 'new', options: { success: true } } }
    end
  end

  def edit
    @user = User.find_by(perishable_token: params[:token])
    render_404 unless @user
  end

  def update
    @user = User.find_by(perishable_token: params[:token])
    if @user.update_attributes(user_params.merge(perishable_token: nil))
      UserSession.create @user, true
      redirect_to profile_path(current_user)
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
