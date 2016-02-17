json.users @users do |user|
  json.partial! 'profile', user: user
end
