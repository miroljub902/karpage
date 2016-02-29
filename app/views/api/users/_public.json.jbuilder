json.name user.name
json.login user.login
json.location user.location
json.profile_url profile_url(user.login) if user.login
json.avatar_url ix_refile_image_url(user, :avatar) if user.avatar
json.cars_count user.cars_count
