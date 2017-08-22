# frozen_string_literal: true

class PushNotification::FollowingNextCar < PushNotification
  def message
    "#{source} changed a next car"
  end

  def notifiable_image_url
    ix_refile_image_url notifiable, :image if notifiable
  end
end
