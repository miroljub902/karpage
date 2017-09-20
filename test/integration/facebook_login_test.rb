# frozen_string_literal: true

require 'test_helper'

class FacebookLoginTest < ActionDispatch::IntegrationTest
  setup do
    omniauth_mock_facebook
    mock_request :s3
    GATracker.stubs(:event!)
  end

  test 'facebook signup' do
    User.any_instance.expects(:send_welcome_email)
    assert_difference 'User.count' do
      auth = OmniAuth.config.mock_auth[:facebook].merge(uid: rand(999_999_999))
      post '/session', { provider: :facebook }, 'omniauth.auth' => auth
      assert_response :found
    end
    user = assigns[:user_session].user
    assert_equal 'facebook', user.identities.first.provider
  end

  test 'facebook login' do
    assert_no_difference 'User.count' do
      post '/session', { provider: :facebook },
           'omniauth.auth' => OmniAuth.config.mock_auth[:facebook]
      assert_response :found
    end
  end
end
