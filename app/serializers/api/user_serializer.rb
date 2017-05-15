class Api::UserSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper

  class PublicProfile < Api::UserSerializer
    attributes %i[id name login location description link instagram_id profile_url cars_count
                  followers_count following_count]
    attribute :following, if: :current_user
    attribute :avatar_url, if: -> { object.avatar }
    attribute :profile_background_url, if: -> { object.profile_background }
    attribute :profile_thumbnail_url, if: -> { object.profile_thumbnail }
  end

  def profile_url
    url(:profile_url, object.login) if object.login
  end

  def followers_count
    object.followers.count
  end

  def following_count
    object.followees.count
  end

  def following
    current_user.following?(object)
  end

  def profile_background_url
    ix_refile_image_url object, :profile_background
  end

  def profile_thumbnail_url
    ix_refile_image_url object, :profile_thumbnail
  end
end
