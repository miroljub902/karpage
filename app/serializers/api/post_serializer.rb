class Api::PostSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper

  attributes %i[id user_id body created_at likes_count upvotes_count image_url]
  attributes %i[liked upvoted], if: :current_user

  has_one :user, serializer: Api::UserSerializer::PublicProfile
  has_many :comments do
    object.comments.sorted
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
    ix_refile_image_url object, :photo
  end
end
