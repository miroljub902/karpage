json.(car, :id, :year, :description, :created_at, :updated_at)

json.make car.make.name
json.model car.object.model.name # car.model gets a Car since it's a decorator

if (photo = car.photos.sorted.first)
  json.image_url ix_refile_image_url(photo, :image)
else
  json.image_url nil
end
