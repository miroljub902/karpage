# frozen_string_literal: true

require 'test_helper'

class Api::UserSerializer::PublicProfileTest < ActiveSupport::TestCase
  test 'does not include private info' do
    user = users(:john_doe)
    serializer = Api::UserSerializer::PublicProfile.new(user)
    serializer.stubs(:current_user).returns(nil)
    json = serializer.to_json
    assert !json.match(/#{user.email}/)
    assert !json.match(/#{user.access_token}/)
  end
end
