require 'test_helper'
require_relative '../api_controller_test'

class Api::LikesControllerTest < ApiControllerTest
  test 'can like a car' do
    user = users(:john_doe)
    friend = users(:friend)
    car = cars(:current)
    friend.cars << car
    authorize_user user
    post :create, car_id: car.id, likeable_type: 'Car'
    assert_response :created
    assert_equal 1, car.reload.likes_count
  end

  test 'can unlike car' do
    user = users(:john_doe)
    friend = users(:friend)
    car = cars(:current)
    friend.cars << car
    Like.like! car, user
    assert_equal 1, car.reload.likes_count
    authorize_user user
    post :destroy, car_id: car.id, likeable_type: 'Car'
    assert_response :ok
    assert_equal 0, car.reload.likes_count
  end
end
