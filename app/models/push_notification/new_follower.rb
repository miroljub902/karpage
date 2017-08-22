# frozen_string_literal: true

class PushNotification::NewFollower < PushNotification
  def message
    "#{source} started following you"
  end

  def notifiable_image_url
    user.avatar ? ix_refile_image_url(user, :avatar) : nil
  end

  def related_id
    notifiable.user_id
  end

  def related_type
    'User'
  end
end
