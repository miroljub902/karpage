require 'test_helper'

class FacebookLoginTest < ActionDispatch::IntegrationTest
  test 'facebook signup' do
    omniauth_mock_facebook
    assert_difference 'User.count' do
      auth = OmniAuth.config.mock_auth[:facebook].merge(uid: rand(999999999))
      post '/session', { provider: :facebook }, { 'omniauth.auth' => auth }
      assert_response :found
    end
    user = assigns[:user_session].user
    assert_equal 'facebook', user.identities.first.provider
  end

  test 'facebook login' do
    omniauth_mock_facebook
    assert_no_difference 'User.count' do
      post '/session', { provider: :facebook }, { 'omniauth.auth' => OmniAuth.config.mock_auth[:facebook] }
      assert_response :found
    end
  end
end
