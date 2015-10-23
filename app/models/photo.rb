class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image
end
