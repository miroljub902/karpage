class HashtagUse < ApplicationRecord
  belongs_to :hashtag, counter_cache: true
  belongs_to :taggable, polymorphic: true
end
