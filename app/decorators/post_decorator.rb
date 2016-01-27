class PostDecorator < Draper::Decorator
  delegate_all
  decorates_association :user

  def truncated_body(length: 400)
    more = h.link_to('Read more', h.post_path(user, self))
    if post.body.size > length
      # simple_format auto_link(truncate(post.body, length: length), html: { target: '_blank' })
      html_body h.truncate(post.body, length: length) + " #{more}".html_safe
    else
      html_body
    end
  end

  def html_body(body = post.body)
    h.simple_format h.auto_link(body, html: { target: '_blank' })
  end
end
