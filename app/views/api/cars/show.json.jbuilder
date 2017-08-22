# frozen_string_literal: true

json.car do
  json.partial! 'car', car: @car

  json.user do
    json.partial! 'api/users/public', user: @car.user
  end

  json.comments @car.comments.limit(12) do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
