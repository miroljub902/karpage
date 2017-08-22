# frozen_string_literal: true

json.user do
  json.partial! @user
  json.new_notifications count_new_stuff(@user.notifications, owner: @user)
  reset_new_stuff @user.notifications, owner: @user
end

json.partial! 'api/profiles/cars', user: @user, cars: UserCarsDecorator.cars(@user)
