class Api::NotificationsController < ApiController
  before_action :require_user

  def index
    @notifications = current_user.notifications.recent.page(params[:page]).per(params[:per] || 10)
    respond_with :api, @notifications
    reset_new_stuff @notifications, owner: current_user
  end
end
