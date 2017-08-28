# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :require_no_user
  skip_before_action :verify_authenticity_token

  layout 'simple'

  def new
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalPasswordReset', content: 'new' } }
    end
  end

  def create
    @user = User.with_login_or_email(params[:login]).first
    @user&.deliver_reset_password_instructions!

    respond_to do |format|
      format.js do
        render '_modals/new', locals: { id: 'modalPasswordReset', content: 'new', options: { success: true } }
      end
    end
  end

  def edit
    @user = params[:token].present? ? User.find_by(perishable_token: params[:token]) : nil
    render_404 unless @user
  end

  def update
    @user = User.find_by!(perishable_token: params[:token])
    if @user.update_attributes(user_params)
      UserSession.create @user, true
      redirect_to @user.login.present? ? profile_path(@user) : root_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
