class ApiController < ActionController::Base
  respond_to :json

  before_action :set_cors_headers

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

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Content-Type, Content-Length, Accept-Encoding"
  end
end
