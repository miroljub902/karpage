# frozen_string_literal: true

module MentionsFormatter
  REGEX = /\B@([\w-]+)/
  MAX_MENTIONS = 5

  private

  def format_mentions(string, limit: MAX_MENTIONS)
    return unless string
    string.dup.tap do |formatted|
      string.scan(REGEX).flatten.uniq[0...limit].each do |mention|
        link = link_to "@#{mention}", profile_path(mention)
        formatted.gsub!(/\B@#{mention}/i, link)
      end
    end
  end
end
