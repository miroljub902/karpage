class PushNotification::FollowingNewFirstCar < PushNotification
  def message
    "#{source} added first car: #{notifiable}"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
