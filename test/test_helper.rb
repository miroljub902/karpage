ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def omniauth_mock_facebook
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: 'facebook',
      uid: identities(:facebook).uid,
      info: {
        nickname: 'jbloggs',
        email: 'joe@bloggs.com',
        name: 'Joe Bloggs',
        first_name: 'Joe',
        last_name: 'Bloggs',
        image: 'http://graph.facebook.com/1234567/picture?type=square',
        urls: { Facebook: 'http://www.facebook.com/jbloggs' },
        location: 'Palo Alto, California',
        verified: true
      },
      credentials: {
        token: 'ABCDEF...',
        expires_at: 1321747205,
        expires: true
      },
      extra: {
        raw_info: {
          id: '1234567',
          name: 'Joe Bloggs',
          first_name: 'Joe',
          last_name: 'Bloggs',
          link: 'http://www.facebook.com/jbloggs',
          username: 'jbloggs',
          location: { id: '123456789', name: 'Palo Alto, California' },
          gender: 'male',
          email: 'joe@bloggs.com',
          timezone: -8,
          locale: 'en_US',
          verified: true,
          updated_time: '2011-11-11T06:21:03+0000'
        }
      }
    })
  end
end
