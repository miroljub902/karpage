json.friends @friends do |friend|
  json.id friend.id
  json.name friend.name
  json.login friend.login
  json.location friend.location
  json.profile_url profile_url(friend.login) if friend.login
  json.avatar_url ix_refile_image_url(friend, :avatar) if friend.avatar
  json.profile_background_url ix_refile_image_url(friend, :profile_background) if friend.profile_background
  json.cars_count friend.cars_count

  json.following friend.follows_by.detect { |f| f.user_id == current_user.id }.present?
end
