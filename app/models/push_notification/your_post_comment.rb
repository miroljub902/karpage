class PushNotification::YourPostComment < PushNotification
  def message
    "#{source} commented on your post"
  end

  def notifiable_image_url
    notifiable.commentable.photo ? ix_refile_image_url(notifiable.commentable, :photo) : nil
  end

  def related_id
    notifiable.commentable_id
  end

  def related_type
    'Post'
  end
end
