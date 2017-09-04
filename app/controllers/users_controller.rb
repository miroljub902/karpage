# frozen_string_literal: true

class UsersController < ApplicationController
  layout 'simple', only: %i[edit update]

  before_action :require_no_user, only: %i[new create]
  before_action :require_user, only: %i[edit update]

  def new
    @user = User.new
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalSignUp', content: 'new' } }
      format.html { redirect_back_or_default root_path }
    end
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      format.js do
        if @user.save
          render inline: "window.location = '#{profile_path(@user)}'"
        else
          render '_modals/new', locals: { id: 'modalSignUp', content: 'new' }
        end
      end
    end
  end

  def edit
    @user = current_user
    respond_to do |format|
      format.js { render '_modals/new', locals: { id: 'modalAccount', content: 'edit' } }
      format.html
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def update
    @user = current_user
    @user.attributes = user_params
    # rubocop:disable Metrics/BlockLength
    respond_to do |format|
      format.js do
        is_profile_page = @user.login && @user.login_was.present? && request.referer == profile_url(@user.login_was)
        location = if @user.login_changed? && is_profile_page
                     %(window.location = "#{profile_path(@user)}")
                   else
                     'window.location.reload()'
                   end
        if @user.save
          render inline: location
        else
          render '_modals/new', locals: { id: 'modalAccount', content: 'edit' }
        end
      end
      format.json do
        if @user.save
          render json: {}
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
      format.html do
        if @user.save
          redirect_to profile_path(current_user), notice: 'Changes saved'
        else
          flash.now.alert = 'Could not update your profile'
          render :edit
        end
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :login, :password, :password_confirmation, :location, :description, :link, :instagram_id,
      :avatar_id, :avatar_content_type, :avatar_size, :avatar_filename, :avatar_crop_params,
      :profile_background_id, :profile_background_content_type, :profile_background_size, :profile_background_filename,
      :profile_background_crop_params,
      :lat, :lng
    )
  end
end
