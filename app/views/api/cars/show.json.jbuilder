json.car do
  json.partial! 'car', car: @car
  if current_user
    json.liked Like.where(likeable: @car, user: current_user).exists?
  end

  json.comments @car.comments.limit(12) do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end
end
