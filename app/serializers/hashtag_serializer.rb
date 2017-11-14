# frozen_string_literal: true

class HashtagSerializer < ActiveModel::Serializer
  attributes :tag, :unique_count
end
