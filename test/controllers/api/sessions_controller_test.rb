require 'test_helper'
require_relative '../api_controller_test'

class Api::SessionsControllerTest < ApiControllerTest
  setup do
    @user = users(:john_doe)
  end

  test 'user can sign in' do
    token = @user.access_token
    post :create, session: { login: @user.email, password: 'password' }
    assert_response :created
    assert_not_equal token, @user.reload.access_token, 'Token did not change'
    assert_equal @user.access_token, json_response['session']['access_token']
  end

  test 'sign out resets access token' do
    token = @user.access_token
    @user.send :generate_access_token!
    authorize_user @user
    post :destroy
    assert_response :ok
    assert_not_equal token, @user.access_token
  end

  test 'sign in via facebook' do
    @user.identities.create! provider: 'facebook', uid: '137110159998964'
    mock_request :facebook_get_me, response: :valid_token
    post :create, session: { facebook_token: '123abc' }
    assert_response :created
    assert_equal @user.reload.access_token, json_response['session']['access_token']
  end

  test 'invalid facebook token' do
    @user.identities.create! provider: 'facebook', uid: '137110159998964'
    mock_request :facebook_get_me, response: :invalid_token
    post :create, session: { facebook_token: '123abc' }
    assert_response :unprocessable_entity
  end
end
