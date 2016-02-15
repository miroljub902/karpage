require 'test_helper'
require_relative '../api_controller_test'

class Api::UsersControllerTest < ApiControllerTest
  test 'can sign up' do
    User.any_instance.stubs(:send_welcome_email)
    assert_difference 'User.count' do
      post :create, user: { login: Faker::Internet.user_name.gsub('.', '-'), email: Faker::Internet.email, password: 'password' }
      assert_response :created
    end
  end

  test 'can update profile' do
    user = users(:john_doe)
    authorize_user user
    patch :update, user: { name: 'New Name' }
    assert_response :ok
    assert_equal 'New Name', json_response['user']['name']
    assert_equal 'New Name', user.reload.name
  end

  test 'can signup with facebook token' do
    User.any_instance.stubs(:send_welcome_email)
    mock_request :facebook_get_me, response: :valid_token
    assert_difference 'User.count + Identity.count', +2 do
      post :create, user: {
        login: Faker::Internet.user_name.gsub('.', '-'),
        email: Faker::Internet.email,
        facebook_token: '123'
      }
      assert_response :created
    end
  end

  test 'cannot signup with existing token' do
    user = users(:john_doe)
    user.identities.create! provider: 'facebook', uid: '137110159998964'
    mock_request :facebook_get_me, response: :valid_token
    assert_no_difference 'User.count + Identity.count' do
      post :create, user: {
        login: Faker::Internet.user_name.gsub('.', '-'),
        email: Faker::Internet.email,
        facebook_token: '123'
      }
      assert_response :unprocessable_entity
    end
  end

  test 'returns avatar url' do
    user = users(:john_doe)
    user.update_attribute :avatar_id, '1234567890'
    authorize_user user
    get :show
    assert_response :ok
    assert json_response['user']['avatar_url'] =~ /1234567890/
  end
end
