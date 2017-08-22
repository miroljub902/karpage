# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::BlocksControllerTest < ApiControllerTest
  test 'can block user' do
    user = users(:john_doe)
    friend = users(:friend)
    assert_difference 'user.blocks.count' do
      authorize_user user
      post :create, params: { profile_id: friend.id }
      assert_response :created
    end
  end
end
