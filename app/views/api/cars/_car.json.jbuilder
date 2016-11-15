UserCarDecorator.new(car).tap do |car|
  json.(car, :id, :year, :description, :created_at, :updated_at, :likes_count)

  json.make car.make&.name
  json.model car.object.model.name # car.model gets a Car since it's a decorator

  json.liked Like.where(likeable: @car, user: current_user).exists? if current_user

  if (photo = car.photos.sorted.first)
    json.image_url ix_refile_image_url(photo, :image)
  else
    json.image_url nil
  end

  json.photos car.photos.sorted do |photo|
    json.partial! 'api/photos/photo', photo: photo
  end

  if car.user == current_user
    json.new_likes count_new_stuff(car.likes, owner: car.user)
    json.new_comments count_new_stuff(car.comments, owner: car.user)
  end
end
