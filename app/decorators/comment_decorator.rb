# frozen_string_literal: true

class CommentDecorator < Draper::Decorator
  include MentionsFormatter
  delegate :link_to, :profile_path, to: :h

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
    h.simple_format format_mentions(body)
  end
end
