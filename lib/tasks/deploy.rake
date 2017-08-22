# frozen_string_literal: true

namespace :deploy do
  task notify_appsignal: :environment do
    env = 'production'
    user = 'deploy'
    revision = `git rev-parse HEAD`.strip

    appsignal_config = Appsignal::Config.new(
      ENV['PWD'],
      env,
      push_api_key: ENV.fetch('APPSIGNAL_PUSH_API_KEY'),
      name: ENV['APPSIGNAL_APP_NAME'] || 'Kar Page'
    )

    marker_data = { revision: revision, user: user }
    marker = Appsignal::Marker.new(marker_data, appsignal_config)
    marker.transmit
  end
end
