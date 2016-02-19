class ApiController < ActionController::Base
  respond_to :json

  before_action :cors_set_headers

  def route_options
    render nothing: true, content_type: 'text/plain'
  end

  def render_404
    render nothing: true, status: :not_found
  end

  # Also on ApplicationController
  def count_new_stuff(stuff, owner:)
    return 0 unless current_user
    NewStuff.count_stuff stuff, current_user, owner: owner
  end
  helper_method :count_new_stuff

  def current_session
    return @current_session if defined?(@current_session)
    @current_session = ::UserSession.new(current_user)
  end

  def current_user
    return @current_user if defined?(@current_user)
    return nil unless request.headers['Authorization'].present?
    @current_user = ::User.find_by(access_token: request.headers['Authorization'])
  end
  helper_method :current_user

  def require_user
    head :unauthorized unless current_user
  end

  def cors_set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, X-Requested-With, X-Prototype-Version, Token, Origin, Accept'
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
