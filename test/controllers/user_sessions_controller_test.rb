require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:john_doe)
  end

  test 'can login with username and password' do
    post :create, user_session: { login: @user.login, password: 'password' }
    assert_response :found
  end

  test 'can login with email and password' do
    post :create, user_session: { login: @user.email, password: 'password' }
    assert_response :found
  end

  test 'invalid credentials' do
    post :create, user_session: { login: @user.login, password: 'invalid' }
    assert flash['warning'].present?
    assert_template :new
  end

  test 'redirects to user profile' do
    skip 'TODO'
  end
end
