class HashtagUse < ApplicationRecord
  belongs_to :hashtag, counter_cache: true
  belongs_to :taggable, polymorphic: true
  belongs_to :relatable, polymorphic: true

  before_save -> { self.relatable ||= taggable }
end
