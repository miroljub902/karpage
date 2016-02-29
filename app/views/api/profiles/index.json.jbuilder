json.users @users do |user|
  json.partial! 'api/users/public', user: user
  json.followers_count user.followers.count
end
