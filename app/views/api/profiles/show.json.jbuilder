json.user do
  json.partial! 'profile', user: @user
end

json.partial! 'cars', user: @user, cars: @cars
