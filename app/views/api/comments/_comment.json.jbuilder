json.(comment, :id, :user_id, :body, :created_at)
json.user do
  json.name comment.user.name
  json.profile_url profile_url(comment.user.login) if comment.user.login
end
