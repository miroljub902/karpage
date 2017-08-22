# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], image_size: 'large',
                                                                      client_options: {
                                                                        site:          'https://graph.facebook.com/v2.8',
                                                                        authorize_url: 'https://www.facebook.com/v2.8/dialog/oauth'
                                                                      }
end
