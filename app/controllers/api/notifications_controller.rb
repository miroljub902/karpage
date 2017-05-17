class Api::NotificationsController < ApiController
  before_action :require_user

  def index
    @notifications = current_user.notifications.page(params[:page]).per(params[:per] || 10)
    respond_with :api, @notifications
  end
end
