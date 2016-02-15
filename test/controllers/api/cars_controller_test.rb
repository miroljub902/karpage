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
end
