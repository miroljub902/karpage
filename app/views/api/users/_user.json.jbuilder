# frozen_string_literal: true

json.call(user, :id, :name, :email, :login, :location, :description, :link, :access_token, :cars_count)
json.avatar_url ix_refile_image_url(user, :avatar)
json.profile_background_url ix_refile_image_url(user, :profile_background)
json.followers_count user.followers.count
json.following_count user.followees.count

# if user.profile_thumbnail
#   json.profile_thumbnail_url ix_refile_image_url(user, :profile_thumbnail)
# else
  json.profile_thumbnail_url image_url('profile/default.jpg')
# end

json.instagram_id user.instagram_id

json.new_posts count_new_stuff(user.friends_posts, owner: nil)
json.new_followers count_new_stuff(user.follows_by, owner: user)
json.push_settings user.push_settings
