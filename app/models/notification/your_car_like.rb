class Notification::YourCarLike < PushNotification
  def message
    "#{source} liked your #{notifiable}"
  end

  def metadata
    photo = notifiable.photos.sorted.first
    super.merge(
      notifiable_image_url: photo ? ix_refile_image_url(photo, :image) : nil
    )
  end
end
