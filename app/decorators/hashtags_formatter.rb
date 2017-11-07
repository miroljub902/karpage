module HashtagsFormatter
  REGEX = /\B#([\w-]+)/
  MAX_HASHTAGS = 5

  private

  def format_hashtags(string, limit: MAX_HASHTAGS)
    return unless string
    string.dup.tap do |formatted|
      string.scan(REGEX).flatten.uniq[0...limit].each do |hashtag|
        link = link_to "##{hashtag}", hashtag_path(hashtag)
        formatted.gsub!(/\B##{hashtag}/i, link)
      end
    end
  end
end
