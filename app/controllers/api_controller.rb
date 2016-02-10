class ApiController < ActionController::Base
  respond_to :json

  def current_session
    return @current_session if defined?(@current_session)
    @current_session = ::UserSession.new(current_user)
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = ::User.find_by(access_token: request.headers['Authorization'])
  end
  helper_method :current_user

  def require_user
    head :unauthorized unless current_user
  end
end
