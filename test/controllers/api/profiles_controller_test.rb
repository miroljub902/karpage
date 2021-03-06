# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::ProfilesControllerTest < ApiControllerTest
  test 'returns index' do
    get :index
    assert_response :ok
  end

  test 'return other user info' do
    user = users(:john_doe)
    get :show, params: { id: user.login }
    assert_response :ok
    assert !json_response['user'].key?('email')
  end

  test 'returns cars' do
    mock_request :s3
    user = users(:john_doe)
    user.dream_cars.create! image_id: 'dummy'
    user.cars << cars(:first)
    user.cars << cars(:current)
    user.cars << cars(:past)
    user.cars << cars(:next)
    get :show, params: { id: user.login }
    %w[next_car first_car current_cars previous_cars dream_cars].each do |key|
      assert json_response.key?(key), "No #{key} key"
      assert_equal 1, json_response[key].size, "#{key} != 1" if json_response[key].is_a?(Array)
      assert json_response[key].present?, "#{key} not present"
    end
  end

  test 'returns post count' do
    user = users(:john_doe)
    user.posts.create! photo_id: 'dummy', body: 'dummy'
    get :show, params: { id: user.login }
    assert_equal 1, json_response['user']['posts_count']
  end

  test 'can follow user' do
    user = users(:john_doe)
    friend = users(:friend)
    authorize_user user
    post :follow, params: { id: friend.login }
    assert_response :created
    assert user.followee_ids.include?(friend.id)
  end

  test 'can unfollow user' do
    user = users(:john_doe)
    friend = users(:friend)
    user.follow! friend
    authorize_user user
    delete :unfollow, params: { id: friend.login }
    assert !user.followee_ids.include?(friend.id)
  end
end
