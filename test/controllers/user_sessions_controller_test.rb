# frozen_string_literal: true

require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:john_doe)
    GATracker.stubs(:event!)
  end

  test 'can login with username and password' do
    post :create, params: { user_session: { login: @user.login, password: 'password' } }
    assert_response :found
  end

  test 'can login with email and password' do
    post :create, params: { user_session: { login: @user.email, password: 'password' } }
    assert_response :found
  end

  test 'invalid credentials' do
    post :create, params: { user_session: { login: @user.login, password: 'invalid' } }
    assert flash[:alert].present?
    assert flash[:alert] =~ /not valid/
  end

  test 'redirects to user profile' do
    post :create, params: { user_session: { login: @user.email, password: 'password' } }
    assert_redirected_to profile_path(@user)
  end
end
