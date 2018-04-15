# frozen_string_literal: true

class CommentDecorator < Draper::Decorator
  include MentionsFormatter
  include HashtagsFormatter
  delegate :link_to, :profile_path, :hashtag_path, to: :h

  delegate_all

  decorates_associations :user

  def commentable_path
    case commentable
    when Car
      h.profile_car_path commentable.user, commentable
    when Post
      h.post_path commentable.user, commentable
    else
      h.url_for commentable
    end
  end

  def formatted_body
    ApplicationHelper.auto_link h.simple_format(format_hashtags(format_mentions(body)))
  end
end
