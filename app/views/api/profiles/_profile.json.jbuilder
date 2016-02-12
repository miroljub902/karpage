json.(user, :name, :login, :location, :description, :link)
json.avatar_url ix_refile_image_url(user, :avatar)
json.profile_background_url ix_refile_image_url(user, :profile_background)
