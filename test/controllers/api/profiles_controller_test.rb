require 'test_helper'
require_relative '../api_controller_test'

class Api::ProfilesControllerTest < ApiControllerTest
  test 'return other user info' do
    users = users(:john_doe)
    get :show, id: users.login
    assert_response :ok
    assert !json_response['user'].has_key?('email')
  end
end
