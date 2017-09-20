# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'user can signup with e-mail and password' do
    ApplicationMailer.any_instance.stubs(:postmark).returns(mock('postmark', deliver_with_template: nil))
    assert_difference 'User.count' do
      post :create, params: { user: {
        email: Faker::Internet.email,
        login: Faker::Internet.user_name,
        password: 'password',
        password_confirmation: 'password'
      }, format: 'js' }
      assert_response :ok
    end
  end

  test 'halts on invalid params' do
    assert_no_difference 'User.count' do
      post :create, params: { user: { email: 'invalid' } }
    end
  end
end
