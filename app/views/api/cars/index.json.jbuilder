json.cars @cars do |car|
  json.(car, :id, :user_id, :year, :description, :first, :current, :past, :likes_count)
  json.make car.make.name
  json.model car.model.name
  json.comments car.comments.limit(12) do |comment|
    json.(comment, :id, :user_id, :body, :created_at)
  end
end
