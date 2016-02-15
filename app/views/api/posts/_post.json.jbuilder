json.(post, :id, :user_id, :body, :created_at)

if post.photo_id?
  json.image_url ix_refile_image_url(post, :photo)
else
  json.image_url nil
end
