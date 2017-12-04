# frozen_string_literal: true

json.total @users.total_count
json.users @users do |user|
  json.call(user, :id, :name, :login, :location, :description, :link, :filtered_cars_count)
  json.profile_url profile_url(user.login) if user.login
  json.avatar_url ix_refile_image_url(user, :avatar) if user.avatar
  json.profile_background_url ix_refile_image_url(user, :profile_background) if user.profile_background
end
