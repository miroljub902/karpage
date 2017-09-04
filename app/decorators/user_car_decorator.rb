# frozen_string_literal: true

class UserCarDecorator < Draper::Decorator
  delegate_all

  decorates_associations :user

  def comments
    model.comments.sorted.decorate
  end

  def first_photo_url
    photo = (photos.loaded? ? photos.sort_by { |p| p.sorting || 1_000 } : photos.sorted).first
    return unless photo
    h.ix_refile_image_url photo, :image, auto: 'enhance,format', fit: 'clip', h: 250
  end
end
