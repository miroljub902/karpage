class UsersController < ApplicationController
  respond_to :html, :js

  layout 'simple', only: %i(edit update)

  before_action :require_no_user, only: %i(new create)
  before_action :require_user, only: %i(show update)

  def show
    @user = current_user
    @cars = UserCarsDecorator.cars(@user)
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
        if @user.save
          render inline: "window.location = '#{user_path}'"
        else
          render '_modals/new', locals: { id: 'modalSignIn', content: 'new' }
        end
      }
    end
  end

  def edit
    @user = current_user
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalAccount', content: 'edit' } }
      format.html
    end
  end

  def update
    @user = current_user
    @user.attributes = user_params
    respond_to do |format|
      format.js {
        if @user.save
          render inline: 'window.location.reload();'
        else
          render '_modals/new', locals: { id: 'modalAccount', content: 'edit' }
        end
      }
      format.html {
        if @user.save
          redirect_to user_path, notice: 'Changes saved'
        else
          flash.now.alert = 'Could not update your profile'
          render :edit
        end
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :login, :password, :password_confirmation)
  end
end
