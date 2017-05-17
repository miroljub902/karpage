class Api::NotificationSerializer < ActiveModel::Serializer
  attributes %i[id type notifiable_id notifiable_type related_id related_type source_id source_type message created_at]
  attributes :image_url, :notifiable_image_url
  attribute :following, if: -> { object.new_follower? }

  delegate :source_id, :image_url, :notifiable_image_url, :notifiable_id, :related_id, :related_type, to: :push_object

  def following
    object.notifiable.user.following?(object.source)
  end

  private

  def push_object
    @_push_object ||= PushNotification.for(object)
  end
end
