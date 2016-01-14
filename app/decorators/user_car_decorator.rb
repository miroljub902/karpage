class UserCarDecorator < Draper::Decorator
  delegate_all

  decorates_associations :user

  def comments
    model.comments.sorted.decorate
  end

  def first_photo_url
    photo = photos.sorted.first
    return unless photo
    if photo.rotate?
      h.attachment_url photo, :image, :fit_and_orient, 720, 250, photo.rotate
    else
      h.attachment_url photo, :image, :fit_and_orient, 720, 250
    end
  end
end
