# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::FriendsControllerTest < ApiControllerTest
  test 'get followers' do
    user = users(:john_doe)
    friend = users(:friend)
    friend.follow! user
    get :followers, params: { profile_id: user.id }
    assert_response :ok
    assert_equal 1, json_response['users'].size
    assert_equal friend.id, json_response['users'].first['id']
  end

  test 'get users followed' do
    user = users(:john_doe)
    friend = users(:friend)
    user.follow! friend
    get :following, params: { profile_id: user.id }
    assert_response :ok
    assert_equal 1, json_response['users'].size
    assert_equal friend.id, json_response['users'].first['id']
  end
end
