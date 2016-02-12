json.user do
  json.partial! 'profile', user: @user
end

json.dream_cars @user.dream_cars, partial: 'api/photos/photo', as: :photo

json.current_cars @cars.current, partial: 'api/cars/car', as: :car
json.previous_cars @cars.past, partial: 'api/cars/car', as: :car

if @user.next_car
  json.next_car @user.next_car, partial: 'api/photos/photo', as: :photo
else
  json.next_car nil
end

if @cars.first
  json.first_car @cars.first, partial: 'api/cars/car', as: :car
else
  json.first_car nil
end

