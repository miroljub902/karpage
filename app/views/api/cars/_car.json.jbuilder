# frozen_string_literal: true

UserCarDecorator.new(car).tap do |car|
  json.call(car,
            :id, :year, :make_id, :model_id, :trim_id, :description, :created_at, :updated_at, :likes_count, :sorting)

  json.make car.make&.name
  json.model car.object.model.name # car.model gets a Car since it's a decorator

  json.liked Like.where(likeable: car.object, user: current_user).exists? if current_user

  if (first_photo = car.photos.sorted.first)
    json.image_url ix_refile_image_url(first_photo, :image)
  else
    json.image_url nil
  end

  json.photos car.photos.sorted do |photo|
    json.partial! 'api/photos/photo', photo: photo
  end

  json.build_list car.parts do |part|
    json.partial! 'api/car_parts/car_part', part: part
  end

  if car.user == current_user
    json.new_likes count_new_stuff(car.likes, owner: car.user)
    json.new_comments count_new_stuff(car.comments, owner: car.user)
  end
end
