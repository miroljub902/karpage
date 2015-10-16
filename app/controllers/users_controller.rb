class UsersController < ApplicationController
  respond_to :html, :js

  layout 'blank', only: %i(new create)

  before_action :require_no_user, only: %i(new create)
  before_action :require_user, only: %i(show update)

  def show
    @user = current_user
    redirect_to edit_user_path if @user.email.blank?
  end

  def new
    @user = User.new
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalSignUp', content: 'new' } }
    end
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      format.js {
        unless @user.save
          render '_modals/new', locals: { id: 'modalSignIn', content: 'new' }
        end
      }
    end
  end

  def edit
    @user = current_user
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalAccount', content: 'edit' } }
    end
  end

  def update
    @user = current_user
    @user.attributes = user_params
    flash_errors_with_save @user
    respond_with @user, location: user_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :login, :password, :password_confirmation)
  end
end
