json.id user.id
json.name user.name
json.login user.login
json.location user.location
json.profile_url profile_url(user.login) if user.login
json.avatar_url ix_refile_image_url(user, :avatar) if user.avatar
json.cars_count user.cars_count
json.followers_count user.followers.count
json.following_count user.followees.count

json.following current_user.following?(user) if current_user
