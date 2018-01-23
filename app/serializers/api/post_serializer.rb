# frozen_string_literal: true

class Api::PostSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper
  include ActionView::Helpers::TextHelper

  attributes %i[id user_id body created_at likes_count upvotes_count image_url]
  attributes %i[liked upvoted], if: :current_user

  has_one :user, serializer: Api::UserSerializer::PublicProfile
  has_many :comments do
    object.comments.sorted
  end
  has_many :photos do
    object.sorted_photos
  end

  def liked
    return object['liked'] if object.attributes.key?('liked')
    Like.where(likeable: object, user: current_user).exists?
  end

  def upvoted
    return object['upvoted'] if object.attributes.key?('upvoted')
    Upvote.where(voteable: object, user: current_user).exists?
  end

  def image_url
    if object.photo_id
      ix_refile_image_url object, :photo
    elsif (photo = object.sorted_photos.first)
      ix_refile_image_url photo, :image
    end
  end

  def body
    simple_format auto_link(object.body, mode: :urls, html: { target: '_blank' })
  end
end
