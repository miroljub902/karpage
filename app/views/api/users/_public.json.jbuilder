# frozen_string_literal: true

json.id user.id
json.name user.name
json.login user.login
json.location user.location
json.description user.description
json.link user.link
json.instagram_id user.instagram_id
json.facebook_url user.facebook_url
json.youtube_url user.youtube_url
json.twitter_url user.twitter_url
json.profile_url profile_url(user.login) if user.login
json.avatar_url ix_refile_image_url(user, :avatar) if user.avatar
json.profile_background_url ix_refile_image_url(user, :profile_background) if user.profile_background
# json.profile_thumbnail_url ix_refile_image_url(user, :profile_thumbnail) if user.profile_thumbnail
json.profile_thumbnail_url image_url('profile/default.jpg')
json.cars_count user.filtered_cars_count
json.followers_count user.followers.count
json.following_count user.followees.count

json.following current_user.following?(user) if current_user
