# frozen_string_literal: true

class PushNotification::FollowingNextCar < PushNotification
  def message
    "#{source} changed a next car"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
