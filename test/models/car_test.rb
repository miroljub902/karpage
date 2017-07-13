require 'test_helper'

class CarTest < ActiveSupport::TestCase
  test 'resorting set of cars' do
    # This happens on after_commit on the model but we have to override it
    # here so tests pass as Rails won't run the after_commit for fixtures
    # (not even with self.transactional_fixtures = true)
    Car.after_update :resort_all, if: :sorting_changed?

    user = users(:john_doe)
    model = models(:audi_r8)
    Car.any_instance.expects(:update_user_profile_thumbnail).at_least_once
    5.times do |i|
      user.cars.create model: model, year: 2015 + i, type: Car.types[:current_car]
    end
    sorting = -> { user.cars.order(sorting: :asc).pluck(:year) }
    assert_equal [2019, 2018, 2017, 2016, 2015], sorting.call
    car = user.cars.find_by(year: 2017)
    car.update_attribute :sorting, car.sorting - 1
    assert_equal [2019, 2017, 2018, 2016, 2015], sorting.call
    car.update_attribute :sorting, 6
    assert_equal [2019, 2018, 2016, 2015, 2017], sorting.call
    car.update_attribute :sorting, 0
    assert_equal [2017, 2019, 2018, 2016, 2015], sorting.call
  end

  test 'creates past car notification' do
    mock_request 's3'
    user = users(:john_doe)
    follower = users(:friend)
    follower.follow! user
    assert_difference 'follower.notifications.following_new_past_car.count' do
      user.cars.create! year: 2015, make_name: 'Audi', car_model_name: 'R8', type: Car.types[:past_car]
    end
  end
end
