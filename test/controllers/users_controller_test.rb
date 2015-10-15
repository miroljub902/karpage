require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'user can signup with e-mail and password' do
    assert_difference 'User.count' do
      post :create, user: { email: Faker::Internet.email, login: Faker::Internet.user_name, password: 'password', password_confirmation: 'password' }
      assert_response :found
    end
    assert_redirected_to user_path
  end

  test 'halts on invalid params' do
    assert_no_difference 'User.count' do
      post :create, user: { email: 'invalid' }
    end
    assert flash[:alert].present?
    assert_template :new
  end
end
