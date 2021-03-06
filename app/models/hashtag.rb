# frozen_string_literal: true

class Hashtag < ApplicationRecord
  has_many :uses, class_name: 'HashtagUse'

  scope :most_used, -> {
    select('hashtags.*, COUNT(hashtag_uses.id) AS recent_uses_count')
      .joins("LEFT OUTER JOIN hashtag_uses ON hashtag_uses.hashtag_id = hashtags.id
                AND hashtag_uses.created_at > '#{30.days.ago.to_s(:db)}'")
      .group('hashtags.id')
      .order('recent_uses_count DESC, hashtag_uses_count DESC, tag ASC')
  }

  scope :simple_search, ->(term) { where('tag ILIKE ?', "%#{term}%") }

  scope :unique_count, -> {
    select('hashtags.*, COUNT(DISTINCT(relatable_id, relatable_type)) AS unique_count')
      .joins(:uses)
      .group('hashtags.id')
  }

  validates :tag, uniqueness: true
end
