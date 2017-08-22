# frozen_string_literal: true

json.call(comment, :id, :user_id, :body, :created_at)
json.user do
  json.partial! 'api/users/public', user: comment.user
end
