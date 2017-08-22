# frozen_string_literal: true

require 'test_helper'
require_relative '../api_controller_test'

class Api::PasswordResetsControllerTest < ApiControllerTest
  test 'sends password reset email' do
    user = users(:john_doe)
    UserMailer.any_instance.stubs(:reset_password!)
    post :create, params: { login: user.login }
    assert_response :created
    previous_token = user.perishable_token
    assert_not_equal previous_token, user.reload.perishable_token
  end

  test 'changes password' do
    user = users(:john_doe)
    user.__send__ :reset_perishable_token!
    patch :update, params: { token: user.perishable_token, user: { password: 'changed' } }
    assert_response :ok
    previous_password = user.crypted_password
    assert_not_equal previous_password, user.reload.crypted_password
    assert user.valid_password?('changed')
  end
end
