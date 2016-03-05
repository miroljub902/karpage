json.car do
  json.partial! 'car', car: @car

  json.comments @car.comments.limit(12) do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
