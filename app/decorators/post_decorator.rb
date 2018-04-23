# frozen_string_literal: true

class PostDecorator < Draper::Decorator
  include MentionsFormatter
  include HashtagsFormatter
  delegate :link_to, :profile_path, :hashtag_path, to: :h

  delegate_all
  decorates_associations :user, :video

  def cover_url(options = {})
    options = { auto: 'enhance,format', format: 'auto', fit: 'clip' }.merge(options)
    if (photo = sorted_photos.first)
      h.ix_refile_image_url(photo, :image, options)
    elsif object.photo
      h.ix_refile_image_url(post, :photo, options)
    elsif (video = object.video)
      video.thumb_url
    end
  end

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
    h.simple_format format_hashtags(format_mentions(Rinku.auto_link(body, :all, 'target="_blank"')))
  end
end
