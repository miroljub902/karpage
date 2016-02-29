json.users @users do |user|
  json.partial! 'api/users/public', user: user
end
