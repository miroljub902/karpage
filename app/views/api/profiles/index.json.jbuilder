json.users @users do |user|
  json.partial! 'api/users/public', user: user
  json.cars_count user.cars_count
  json.followers_count user.followers.count
end
