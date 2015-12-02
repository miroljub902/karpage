Rails.application.config.middleware.use OmniAuth::Builder do
  Rails.logger.info "Facebook App Id: #{ENV['FACEBOOK_APP_ID']}"
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], image_size: 'large'
end
