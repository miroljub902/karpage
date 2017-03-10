require 'test_helper'

class CarPartTest < ActiveSupport::TestCase
  test 'initialize sorting' do
    user = users(:john_doe)
    car = cars(:current)
    car.expects(:update_user_profile_thumbnail).at_least_once
    user.cars << car
    part = car.parts.create! type: 'Wheel'
    assert_equal 0, part.reload.sorting
    part = car.parts.create! type: 'Wheel'
    assert_equal 1, part.reload.sorting
  end
end
