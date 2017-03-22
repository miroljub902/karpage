require 'test_helper'
require_relative '../api_controller_test'

class Api::BlocksControllerTest < ApiControllerTest
  test 'can block user' do
    user = users(:john_doe)
    fiend = users(:friend)
    assert_difference 'user.blocks.count' do
      authorize_user user
      post :create, profile_id: fiend.id
      assert_response :created
    end
  end
end
