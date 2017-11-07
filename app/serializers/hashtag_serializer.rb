class HashtagSerializer < ActiveModel::Serializer
  attributes :tag, :unique_count
end
