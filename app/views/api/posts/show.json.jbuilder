# frozen_string_literal: true

json.post do
  json.partial! 'post', post: @post

  json.comments @post.comments.sorted do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
