# frozen_string_literal: true

class UserCarDecorator < Draper::Decorator
  include MentionsFormatter
  include HashtagsFormatter
  delegate :link_to, :profile_path, :hashtag_path, to: :h

  delegate_all

  decorates_associations :user

  def comments
    model.comments.sorted.includes(:user, recent_comments: [:user, { commentable: :user }], commentable: :user).decorate
  end

  def first_photo_url
    photo = (photos.loaded? ? photos.sort_by { |p| p.sorting || 1_000 } : photos.sorted).first
    return unless photo
    h.ix_refile_image_url photo, :image, auto: 'enhance,format', fit: 'clip', h: 250
  end

  def formatted_description
    h.simple_format format_hashtags(format_mentions(description))
  end
end
