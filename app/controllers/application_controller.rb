class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def signed_in?
    current_user.present?
  end
  helper_method :signed_in?

  private

  def require_no_user
    redirect_back_or_default root_path if current_user
  end

  def require_user
    redirect_to new_user_session_path unless current_user
  end

  def redirect_back_or_default(default)
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to default
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def flash_errors_with_save(record)
    verb = record.new_record? ? 'created' : 'updated'
    if record.save
      flash[:notice] = I18n.t("#{record.class.model_name.param_key}.flash.#{verb}")
    else
      flash.now[:warning] = record.errors.full_messages.join(', ')
    end
  end
end
