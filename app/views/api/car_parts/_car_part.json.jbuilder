# frozen_string_literal: true

json.call(part, :id, :type, :manufacturer, :model, :price, :link, :review, :sorting, :created_at)
if part.photo
  json.photo do
    json.partial! 'api/photos/photo', photo: part.photo
  end
end
