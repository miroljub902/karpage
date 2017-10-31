# frozen_string_literal: true

class CommentDecorator < Draper::Decorator
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
end
