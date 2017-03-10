json.(part, :id, :type, :manufacturer, :model, :price, :review, :sorting, :created_at)
if part.photo
  json.photo do
    json.partial! 'api/photos/photo', photo: part.photo
  end
end
