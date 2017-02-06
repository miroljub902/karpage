class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image, content_type: :image

  before_save -> do
    if attachable.respond_to?(:photos)
      self.sorting ||= (attachable.photos.maximum(:sorting) || -1) + 1
    else
      self.sorting ||= 0
    end
    true
  end
end
