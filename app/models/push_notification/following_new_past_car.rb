# frozen_string_literal: true

class PushNotification::FollowingNewPastCar < PushNotification
  def message
    "#{source} added a previous car: #{notifiable}"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
