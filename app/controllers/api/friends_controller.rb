class Api::FriendsController < ApiController
  before_action :require_user

  def index
    @friends = current_user.friends.includes(:follows_by)
  end
end
