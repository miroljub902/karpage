class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image

  before_create -> do
    if attachable.respond_to?(:photos)
      self.sorting = (attachable.photos.maximum(:sorting) || -1) + 1
    end
    true
  end
end
