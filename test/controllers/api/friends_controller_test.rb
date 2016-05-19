require 'test_helper'
require_relative '../api_controller_test'

class Api::FriendsControllerTest < ApiControllerTest
  test 'get friends' do
    user = users(:john_doe)
    friend = users(:friend)
    user.follow! friend
    authorize_user user
    get :index
    assert_response :ok
    assert_equal 1, json_response['friends'].size
    assert_equal friend.id, json_response['friends'].first['id']
    assert json_response['friends'].first['following']
  end
end
