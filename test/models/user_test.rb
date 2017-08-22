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
end
