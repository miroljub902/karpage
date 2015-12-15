class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image

  before_create -> do
    self.sorting = (attachable.photos.maximum(:sorting) || -1) + 1
  end
end
