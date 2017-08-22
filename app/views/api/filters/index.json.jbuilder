# frozen_string_literal: true

json.filters @filters do |filter|
  json.call(filter, :id, :name)
end
