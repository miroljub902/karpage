class ApiController < ApplicationController
  respond_to :json

  def current_api_session
    return @current_api_session if defined?(@current_api_session)
    @current_api_session = ::UserSession.new(current_api_user)
  end

  def current_api_user
    return @current_api_user if defined?(@current_api_user)
    @current_api_user = User.find_by(access_token: request.headers['Authorization'])
  end
  helper_method :current_api_user

  def require_api_user
    head :unauthorized unless current_api_user
  end
end
