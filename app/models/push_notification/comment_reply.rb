# frozen_string_literal: true

class PushNotification::CommentReply < PushNotification
  def message
    body = notifiable.body.truncate(20)
    "#{source} replied to your comment on #{notifiable.commentable.commentable}: #{body}"
  end

  def notifiable_image_url
    notifiable.user.avatar ? ix_refile_image_url(notifiable.user, :avatar) : nil
  end

  def related_id
    notifiable.commentable_id
  end

  def related_type
    'Comment'
  end
end
