json.(part, :type, :manufacturer, :model, :price, :created_at)
if part.photo
  json.photo do
    json.partial! 'api/photos/photo', photo: part.photo
  end
end
