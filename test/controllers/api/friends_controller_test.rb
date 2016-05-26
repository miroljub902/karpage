require 'test_helper'
require_relative '../api_controller_test'

class Api::FriendsControllerTest < ApiControllerTest
  test 'get followers' do
    user = users(:john_doe)
    friend = users(:friend)
    friend.follow! user
    authorize_user user
    get :followers
    assert_response :ok
    assert_equal 1, json_response['users'].size
    assert_equal friend.id, json_response['users'].first['id']
  end

  test 'get users followed' do
    user = users(:john_doe)
    friend = users(:friend)
    user.follow! friend
    authorize_user user
    get :following
    assert_response :ok
    assert_equal 1, json_response['users'].size
    assert_equal friend.id, json_response['users'].first['id']
  end
end
