# frozen_string_literal: true

::Imgix::Rails.configure do |config|
  config.imgix = {
    source: ENV.fetch('IMGIX_SOURCE')
  }
end
