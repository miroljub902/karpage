class UsersController < ApplicationController
  respond_to :html, :js, :json

  layout 'simple', only: %i(edit update)

  before_action :require_no_user, only: %i(new create)
  before_action :require_user, only: %i(update)

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
          render inline: "window.location = '#{profile_path(@user)}'"
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
        is_profile_page = @user.login && request.referer == profile_url(@user.login_was)
        location = @user.login_changed? && is_profile_page ? %Q(window.location = "#{profile_path(@user)}") : 'window.location.reload()'
        if @user.save
          render inline: location
        else
          render '_modals/new', locals: { id: 'modalAccount', content: 'edit' }
        end
      }
      format.json {
        if @user.save
          render json: {}
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      }
      format.html {
        if @user.save
          redirect_to profile_path(current_user), notice: 'Changes saved'
        else
          flash.now.alert = 'Could not update your profile'
          render :edit
        end
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :login, :password, :password_confirmation, :location, :description, :twitter_uid,
      :avatar_id, :avatar_content_type, :avatar_size, :avatar_filename,
      :profile_background_id, :profile_background_content_type, :profile_background_size, :profile_background_filename
    )
  end
end
