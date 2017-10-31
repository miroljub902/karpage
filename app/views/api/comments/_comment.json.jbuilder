# frozen_string_literal: true

json.call(comment, :id, :user_id, :body, :created_at)
json.user do
  json.partial! 'api/users/public', user: comment.user
end

unless comment.commentable.is_a?(Comment)
  json.replies comment.comments do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
