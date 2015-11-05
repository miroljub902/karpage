class UserDecorator < Draper::Decorator
  delegate_all

  def initials
    model.name.to_s.split(' ')[0..1].map { |n| n.first.upcase }.join.presence || '?'
  end

  def twitter_link
    return unless model.twitter_uid.present?
    h.link_to "twitter.com/#{model.twitter_uid}", "https://twitter.com/#{model.twitter_uid}", target: '_blank'
  end
end
