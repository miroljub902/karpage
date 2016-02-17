json.(user, :id, :name, :email, :login, :location, :description, :link, :access_token, :cars_count)
json.avatar_url ix_refile_image_url(user, :avatar)
json.profile_background_url ix_refile_image_url(user, :profile_background)
json.followers_count user.followers.count
json.following_count user.followees.count
