# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_complete_profile

  rescue_from ActionController::UnknownFormat, with: :render_404
  rescue_from ActionController::InvalidCrossOriginRequest do |_exception|
    render_403 unless performed?
  end
  rescue_from ActionController::InvalidAuthenticityToken do
    respond_to do |format|
      format.js do
        render inline: 'alert("Your session has expired, please reload the page.")'
      end
      format.html do
        render template: 'application/message',
               locals: { message: 'Your session has expired, please go back and reload the page.' },
               layout: 'simple'
      end
    end
  end

  def api_base
    subdomain = ENV.fetch('API_SUBDOMAIN')
    host = ENV.fetch('HOSTNAME').sub(/^www\./, '')
    subdomain = host.start_with?("#{subdomain}.") ? '' : "#{subdomain}."
    "#{subdomain}#{host}"
  end
  helper_method :api_base

  def signed_in?
    current_user.present?
  end
  helper_method :signed_in?

  # Also on ApiController
  def count_new_stuff(stuff, owner:)
    NewStuff.count_stuff stuff, current_user, owner: owner
  end
  helper_method :count_new_stuff

  def reset_new_stuff(stuff, owner:)
    NewStuff.reset_count stuff, current_user, owner: owner
  end
  helper_method :reset_new_stuff

  private

  # Bad users could request with array or hash params when we expect a simple string or integer
  def sanitize_string_params(*param_names)
    param_names.each do |param|
      params[param] = params[param].to_s
    end
  end

  def require_complete_profile
    return if !signed_in? || (controller_name == 'users' && %w[edit update].include?(action_name))
    redirect_to edit_user_path, notice: 'Please provide a username and e-mail' if current_user.incomplete_profile?
  end

  def render_403
    respond_to do |format|
      format.html do
        render file: 'public/404', status: :forbidden, layout: false
      end
      format.any do
        head :forbidden
      end
    end
  end

  def render_404
    respond_to do |format|
      format.html do
        render file: 'public/404', status: :not_found, layout: false
      end
      format.any do
        head :not_found
      end
    end
  end

  def respond_to_js(&block)
    respond_to do |format|
      format.js(&block)
      format.html do
        render file: 'public/js_required', status: :bad_request, layout: false
      end
    end
  end

  def require_no_user
    redirect_back_or_default root_path if current_user
  end

  def require_user
    return if current_user
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'You must be logged in' }
      format.js do
        @user_session = UserSession.new
        render '_modals/new', locals: { id: 'modalSignIn', content: 'user_sessions/new' }
      end
    end
  end

  def redirect_back_or_default(default, options = {})
    redirect_back fallback_location: default, **options
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = ::UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session&.user&.decorate
  end
  helper_method :current_user

  def current_admin_user
    current_user&.admin? ? current_user : nil
  end

  def authenticate_admin_user!
    return if current_user&.admin?
    render_404
  end

  def flash_errors_with_save(record)
    verb = record.new_record? ? 'created' : 'updated'
    if record.save
      flash[:notice] = ::I18n.t("#{record.class.model_name.param_key}.flash.#{verb}")
    else
      flash.now[:alert] = record.errors.full_messages.join(', ')
    end
  end
end
