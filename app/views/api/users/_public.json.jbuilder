# frozen_string_literal: true

json.call(user, :id, :name, :login, :location, :description, :link, :instagram_id, :facebook_url, :youtube_url,
          :twitter_url, :posts_count, :gender)

json.profile_url profile_url(user.login) if user.login
json.avatar_url ix_refile_image_url(user, :avatar) if user.avatar
json.profile_background_url ix_refile_image_url(user, :profile_background) if user.profile_background
json.profile_thumbnail_url image_url('profile/default.jpg')
json.cars_count user.filtered_cars_count
json.followers_count user.followers.count
json.following_count user.followees.count

json.following current_user.following?(user) if current_user
