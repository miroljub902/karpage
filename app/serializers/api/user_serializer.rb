# frozen_string_literal: true

class Api::UserSerializer < ApiSerializer
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper
  include ActionView::Helpers::AssetUrlHelper

  attributes %i[
    id name email login location description link access_token cars_count profile_url
    avatar_url profile_background_url followers_count following_count profile_thumbnail_url
    instagram_id facebook_url youtube_url twitter_url
    new_posts new_followers push_settings
  ]

  class PublicProfile < Api::UserSerializer
    attribute :email, if: -> { false }
    attribute :access_token, if: -> { false }
    attribute :following, if: :current_user
    attribute :avatar_url, if: -> { object.avatar }
    attribute :profile_background_url, if: -> { object.profile_background }
    attribute :profile_thumbnail_url
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

  def avatar_url
    ix_refile_image_url object, :avatar
  end

  def profile_background_url
    ix_refile_image_url object, :profile_background
  end

  def profile_thumbnail_url
    # ix_refile_image_url object, :profile_thumbnail
    image_url 'profile/default.jpg'
  end

  def new_posts
    count_new_stuff object.friends_posts, owner: nil
  end

  def new_followers
    count_new_stuff object.follows_by, owner: object
  end
end
