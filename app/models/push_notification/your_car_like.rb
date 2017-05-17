class PushNotification::YourCarLike < PushNotification
  def message
    "#{source} liked your #{notifiable}"
  end

  def notifiable_image_url
    photo = notifiable.photos.sorted.first
    photo ? ix_refile_image_url(photo, :image) : nil
  end

  def related_id
    notifiable.commentable_id
  end

  def related_type
    'Car'
  end
end
