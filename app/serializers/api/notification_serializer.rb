# frozen_string_literal: true

class Api::NotificationSerializer < ActiveModel::Serializer
  attributes %i[id type notifiable_id notifiable_type related_id related_type source_id source_type message created_at]
  attributes :image_url, :notifiable_image_url
  attribute :following, if: -> { object.new_follower? }
  attribute :plain_body, if: -> { object.notifiable_type == 'Comment' }

  delegate :source_id, :image_url, :notifiable_image_url, :notifiable_id, :related_id, :related_type, to: :push_object

  def plain_body
    object.notifiable.body
  end

  def following
    if object.notifiable.is_a?(Follow)
      object.user.following?(object.source)
    else
      object.notifiable.user.following?(object.source)
    end
  end

  private

  def push_object
    @_push_object ||= PushNotification.for(object)
  end
end
