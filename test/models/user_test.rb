# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'sends welcome e-mail' do
    user = User.create!(identities: [Identity.new(provider: 'facebook', uid: rand(999_999))])
    user.expects :send_welcome_email
    user.update_attributes email: Faker::Internet.email
  end

  test 'does not send welcome e-mail if user has no e-mail address' do
    user = users(:john_doe)
    user.expects(:send_welcome_email).never
    user.update_attributes email: Faker::Internet.email
  end

  test 'return friends' do
    user = users(:john_doe)
    friend1 = users(:friend)
    friend2 = User.create!(identities: [Identity.new(provider: 'facebook', uid: rand(999_999))])
    not_friend = User.create!(identities: [Identity.new(provider: 'facebook', uid: rand(999_999))])
    not_friend2 = User.create!(identities: [Identity.new(provider: 'facebook', uid: rand(999_999))])
    not_friend.follow! not_friend2
    user.follow! friend1
    friend2.follow! user
    friends = user.friends
    assert_equal 2, friends.size
    assert_equal [friend1.id, friend2.id].sort, friends.map(&:id).sort
  end

  test 'updates cars_count correctly' do
    mock_request 's3'
    user = users(:john_doe)
    cars = []
    cars.push user.cars.create!(year: 2015, make_name: 'Audi', car_model_name: 'R8', type: Car.types[:next_car])
    assert_equal 1, user.reload.cars_count
    assert_equal 0, user.reload.filtered_cars_count
    cars.push user.cars.create!(year: 2015, make_name: 'Audi', car_model_name: 'R8', type: Car.types[:current_car])
    assert_equal 2, user.reload.cars_count
    assert_equal 1, user.reload.filtered_cars_count
    cars.each(&:destroy)
    assert_equal 0, user.reload.cars_count
    assert_equal 0, user.reload.filtered_cars_count
  end
end
