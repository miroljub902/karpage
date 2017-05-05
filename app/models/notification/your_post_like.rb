class Notification::YourPostLike < PushNotification
  def message
    "#{source} liked your post"
  end

  def metadata
    super.merge(
      notifiable_image_url: notifiable.photo ? ix_refile_image_url(notifiable.photo, :image) : nil
    )
  end
end
