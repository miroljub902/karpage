# frozen_string_literal: true

class Api::ProductSerializer < ActiveModel::Serializer
  attributes %i[id title subtitle price link description category]
  has_many :photos
end
