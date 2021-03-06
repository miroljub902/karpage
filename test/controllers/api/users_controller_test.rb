# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

# rubocop:disable Metrics/ClassLength
class Api::UsersControllerTest < ApiControllerTest
  test 'can sign up' do
    User.any_instance.stubs(:send_welcome_email)
    mock_request :s3
    GATracker.stubs(:event!)
    assert_difference 'User.count' do
      post :create,
           params: {
             user: {
               login: Faker::Internet.user_name.tr('.', '_'),
               email: Faker::Internet.email,
               password: 'password'
             }
           }
      assert_response :created
    end
  end

  test 'disallow duplicate email' do
    existing = users(:john_doe)
    assert_no_difference 'User.count' do
      post :create, params: { user: { email: existing.email, login: Faker::Internet.user_name, password: 'password' } }
      assert_response :unprocessable_entity
    end
  end

  test 'disallow duplicate login' do
    existing = users(:john_doe)
    assert_no_difference 'User.count' do
      post :create, params: { user: { email: Faker::Internet.email, login: existing.login, password: 'password' } }
      assert_response :unprocessable_entity
    end
  end

  test 'tracks signup' do
    User.any_instance.stubs(:send_welcome_email)
    mock_request 's3'
    GATracker.expects(:event!).with do |user, opts|
      user.is_a?(User) &&
        opts[:category] == 'user' &&
        opts[:action] == 'signup' &&
        opts[:label] == 'android' &&
        opts[:value] == 1
    end
    @request.headers['User-Agent'] = 'Mozilla/5.0 (Linux; Android 5.1.1; wv) Version/4.0 Chrome/48.0.2564.106'
    post :create, params: { user: {
      login:    Faker::Internet.user_name.tr('.', '-'),
      email:    Faker::Internet.email,
      password: 'password'
    } }
  end

  test 'does not track failed signup' do
    User.any_instance.stubs(:send_welcome_email)
    GATracker.expects(:event!).never
    post :create, params: { user: { login: '' } }
  end

  test 'returns whats new' do
    mock_request :s3
    user   = users(:john_doe)
    friend = users(:friend)
    NewStuff.reset_count(user.friends_posts, user, owner: nil, delay: true)
    NewStuff.reset_count(user.follows_by, user, owner: user, delay: true)
    friend.followers << user
    user.followers << friend
    friend.posts.create! body: 'Howdy', photo_id: 'dummy'
    authorize_user user
    get :show
    assert_equal 1, json_response['user']['new_posts']
    assert_equal 1, json_response['user']['new_followers']
  end

  test 'returns whats new counters' do
    mock_request :s3
    user   = users(:john_doe)
    friend = users(:friend)
    NewStuff.reset_count(user.friends_posts, user, owner: nil, delay: true)
    NewStuff.reset_count(user.follows_by, user, owner: user, delay: true)
    friend.followers << user
    user.followers << friend
    friend.posts.create! body: 'Howdy', photo_id: 'dummy'
    authorize_user user
    put :reset_counter, params: { counter: 'friends_posts' }
    get :show
    assert_equal 0, json_response['user']['new_posts']
    assert_equal 1, json_response['user']['new_followers']
  end

  test 'can update profile' do
    user = users(:john_doe)
    authorize_user user
    mock_request :s3
    patch :update, params: { user: { name: 'New Name' } }
    assert_response :ok
    assert_equal 'New Name', json_response['user']['name']
    assert_equal 'New Name', user.reload.name
  end

  test 'can signup with facebook token' do
    User.any_instance.stubs(:send_welcome_email)
    mock_request :s3
    GATracker.stubs(:event!)
    mock_request :facebook_get_me, response: :valid_token
    assert_difference 'User.count + Identity.count', +2 do
      post :create, params: { user: {
        login:          Faker::Internet.user_name.tr('.', '_'),
        email:          Faker::Internet.email,
        facebook_token: '123'
      } }
      assert_response :created
    end
  end

  test 'cannot signup with existing token' do
    user = users(:john_doe)
    user.identities.create! provider: 'facebook', uid: '137110159998964'
    mock_request :facebook_get_me, response: :valid_token
    assert_no_difference 'User.count + Identity.count' do
      post :create, params: { user: {
        login:          Faker::Internet.user_name.tr('.', '_'),
        email:          Faker::Internet.email,
        facebook_token: '123'
      } }
      assert_response :unprocessable_entity
    end
  end

  test 'returns avatar url' do
    user = users(:john_doe)
    mock_request :s3
    user.update_attribute :avatar_id, '1234567890'
    authorize_user user
    get :show
    assert_response :ok
    assert json_response['user']['avatar_url'] =~ /1234567890/
  end

  test 'can add dream cars' do
    mock_request :s3
    user = users(:john_doe)
    authorize_user user
    patch :update, params: { user: { dream_cars_attributes: [{ image_id: 'dummy' }] } }
    assert_response :ok
    assert_equal 1, user.dream_cars.count
    assert_equal 'dummy', user.dream_cars.first.image_id
  end

  test 'can update push settings' do
    user = users(:john_doe)
    authorize_user user
    setting = User::DEFAULT_PUSH_SETTINGS.first
    patch :update, params: { user: { push_settings: { setting[0] => !setting[1] } } }
    assert_equal !setting[1], user.reload.push_setting?(setting[0])
  end
end
