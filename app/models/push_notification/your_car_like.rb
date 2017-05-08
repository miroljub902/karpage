class PushNotification::YourCarLike < PushNotification
  def message
    "#{source} liked your #{notifiable}"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end
end
