# frozen_string_literal: true

class Api::PasswordResetsController < ApiController
  def create
    @user = User.with_login_or_email(params.require(:login)).first
    return render_404 unless @user
    @user.deliver_reset_password_instructions!
    render nothing: true, status: :created
  end

  def update
    @user = User.find_by(perishable_token: params.require(:token))
    if @user.update_attributes(user_params)
      UserSession.create @user, true
      render nothing: true, status: :ok
    else
      respond_with @user
    end
  end

  private

  def user_params
    params.require(:user).permit(:password).merge(password_confirmation: params[:user][:password])
  end
end
