require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'sends welcome e-mail' do
    user = User.create!(identities: [ Identity.new(provider: 'facebook', uid: rand(999999)) ])
    user.expects :send_welcome_email
    user.update_attributes email: Faker::Internet.email
  end

  test 'does not send welcome e-mail if user has no e-mail address' do
    user = users(:john_doe)
    user.expects(:send_welcome_email).never
    user.update_attributes email: Faker::Internet.email
  end
end
