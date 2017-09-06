# frozen_string_literal: true

require 'test_helper'

class UserCarsControllerTest < ActionController::TestCase
  setup do
    mock_request :s3
  end

  test 'creates makes, models, trims automatically' do
    user = users(:john_doe)
    UserSession.create user
    assert_difference 'Make.count + Model.count + Trim.count', +3 do
      post :create, car: {
        year: 2017,
        make_name: 'Custom Make',
        car_model_name: 'Custom Model',
        trim_name: 'Custom Trim',
        type: Car.types[:current_car]
      }, format: :js
      assert_response :created
    end
    car = user.cars.last
    assert_equal 'Custom Make', car.make.name
    assert_equal 'Custom Model', car.model.name
    assert_equal 'Custom Trim', car.trim.name
  end
end
