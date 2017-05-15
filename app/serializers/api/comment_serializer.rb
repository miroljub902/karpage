class Api::CommentSerializer < ApiSerializer
  attributes %i[id user_id body created_at]
  has_one :user, serializer: Api::UserSerializer::PublicProfile
end
