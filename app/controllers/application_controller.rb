class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def signed_in?
    current_user.present?
  end
  helper_method :signed_in?

  private

  def render_404
    render file: 'public/404', status: :not_found, layout: false
  end

  def require_no_user
    redirect_back_or_default root_path if current_user
  end

  def require_user
    redirect_to root_path unless current_user
  end

  def redirect_back_or_default(default, options = {})
    redirect_to :back, options
  rescue ActionController::RedirectBackError
    redirect_to default, options
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  helper_method :current_user

  def flash_errors_with_save(record)
    verb = record.new_record? ? 'created' : 'updated'
    if record.save
      flash[:notice] = I18n.t("#{record.class.model_name.param_key}.flash.#{verb}")
    else
      flash.now[:alert] = record.errors.full_messages.join(', ')
    end
  end
end
