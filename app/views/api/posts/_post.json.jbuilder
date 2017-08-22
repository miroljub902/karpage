# frozen_string_literal: true

json.call(post, :id, :user_id, :body, :created_at, :likes_count)

if current_user
  json.liked Like.where(likeable: post, user: current_user).exists?
end

if post.photo_id?
  json.image_url ix_refile_image_url(post, :photo)
else
  json.image_url nil
end

json.user do
  json.partial! 'api/users/public', user: post.user
end
