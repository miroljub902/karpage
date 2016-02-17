require 'test_helper'
require_relative '../api_controller_test'

class Api::CarsControllerTest < ApiControllerTest
  test 'returns cars' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    car.photos.create! image_id: 'dummy'
    car.comments.create! user: users(:friend), body: 'Nice car'
    get :index
    assert_response :ok
  end

  test 'can create car' do
    user = users(:john_doe)
    authorize_user user
    assert_difference 'user.cars.count' do
      post :create, car: { year: '2015', make_name: 'Audi', car_model_name: 'R8' }
      assert_response :created
    end
  end

  test 'can update car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    patch :update, id: car.id, car: { description: 'Updated' }
    assert_response :no_content
    assert_equal 'Updated', car.reload.description
  end

  test 'returns car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    get :show, id: car.id
    assert_response :ok
  end

  test 'returns whats new' do
    user = users(:john_doe)
    friend = users(:friend)
    car = cars(:current)
    user.cars << car
    NewStuff.reset_count(car.likes, user, owner: user, delay: true)
    NewStuff.reset_count(car.comments, user, owner: user, delay: true)
    Like.like! car, friend
    car.comments.create! user: friend, body: 'Howdy'
    authorize_user user
    get :show, id: car.id
    assert_equal 1, json_response['car']['new_likes']
    assert_equal 1, json_response['car']['new_comments']
  end

  test 'can destroy car' do
    user = users(:john_doe)
    user.cars << cars(:current)
    car = user.cars.first
    authorize_user user
    delete :destroy, id: car.id
    assert_response :no_content
    assert_raise { car.reload }
  end
end
