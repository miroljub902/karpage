require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'user can signup with e-mail and password' do
    post :create, user: { email: Faker::Internet.email, login: Faker::Internet.user_name, password: 'password', password_confirmation: 'password' }
    assert_response :found
    assert_redirected_to user_path
  end

  test 'halts on invalid params' do
    post :create, user: { email: 'invalid' }
    assert flash[:alert].present?
    assert_template :new
  end
end
