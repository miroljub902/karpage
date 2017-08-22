# frozen_string_literal: true

class PostDecorator < Draper::Decorator
  delegate_all
  decorates_association :user

  # rubocop:disable Metrics/AbcSize
  def truncated_body(length: 400)
    more = h.link_to('Read more', h.post_path(user, self))
    if post.body.size > length
      html_body h.safe_join([h.truncate(post.body, length: length), " #{more}".html_safe])
    else
      html_body
    end
  end

  def html_body(body = post.body)
    h.simple_format h.auto_link(body, html: { target: '_blank' })
  end
end
