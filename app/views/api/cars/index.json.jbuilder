json.total @total_count
json.cars @cars do |car|
  json.partial! 'car', car: car

  json.comments car.comments.limit(12) do |comment|
    json.partial! 'api/comments/comment', comment: comment
  end

  json.user do
    json.partial! 'api/users/public', user: car.user
  end
end
