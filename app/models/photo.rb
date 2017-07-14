class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image, type: :image

  before_save -> do
    if attachable.respond_to?(:photos)
      self.sorting ||= (attachable.photos.maximum(:sorting) || -1) + 1
    else
      self.sorting ||= 0
    end
    true
  end

  concerning :Notifications do
    included do
      after_create -> {
        type = Notification.types[:following_dream_car]
        attachable.followers.each do |follower|
          follower.notifications.create! type: type, notifiable: self, source: attachable
        end
      }, if: -> { photo_type == 'dream-car' }
    end
  end
end
