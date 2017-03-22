Apipie.configure do |config|
  config.app_name                = 'Kar Page'
  config.api_base_url            = '/api'
  config.doc_base_url            = '/apipie'
  config.app_info                = 'API documentation (WIP)'
  config.validate                = false
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"

  if Rails.env.production?
    config.authenticate = Proc.new do
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV.fetch('APIPIE_USER') && password == ENV.fetch('APIPIE_PASSWORD')
      end
    end
  end
end
