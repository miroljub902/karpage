class Photo < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  scope :sorted, -> { order(sorting: :asc) }

  attachment :image, type: :image

  validate :validate_image_size

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
        type = Notification.types[:following_next_car]
        attachable.followers.each do |follower|
          follower.notifications.create! type: type, notifiable: self, source: attachable
        end
      }, if: -> { photo_type == 'next-car' }

      after_create -> {
        type = Notification.types[:following_dream_car]
        attachable.followers.each do |follower|
          follower.notifications.create! type: type, notifiable: self, source: attachable
        end
      }, if: -> { photo_type == 'dream-car' }
    end
  end

  private

  def validate_image_size
    # Sometimes image.size will be nil so treat as too big
    image_size = self.image_size.presence || image&.size || image&.backend&.max_size
    return if image.nil? || image_size < image.backend.max_size
    errors.add :image, :too_large
  end
end
