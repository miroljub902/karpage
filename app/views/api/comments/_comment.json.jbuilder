# frozen_string_literal: true

json.call(comment, :id, :user_id, :created_at)
json.body Rinku.auto_link(comment.body, :all, 'target="_blank"')
json.image_url ix_refile_image_url comment, :photo

json.user do
  json.partial! 'api/users/public', user: comment.user
end

unless comment.commentable.is_a?(Comment)
  json.replies comment.comments do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
