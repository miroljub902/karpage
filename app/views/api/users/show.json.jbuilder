json.user do
  json.partial! @user
end

json.partial! 'api/profiles/cars', user: @user, cars: UserCarsDecorator.cars(@user)
