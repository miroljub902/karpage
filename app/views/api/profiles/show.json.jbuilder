# frozen_string_literal: true

json.user do
  json.partial! 'api/users/public', user: @user
end

json.partial! 'cars', user: @user, cars: @cars
