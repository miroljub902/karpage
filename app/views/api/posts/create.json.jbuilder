# frozen_string_literal: true

json.post do
  json.partial! 'post', post: @post
end
