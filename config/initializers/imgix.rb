::Imgix::Rails.configure do |config|
  config.imgix = {
    source: ENV.fetch('IMGIX_SOURCE')
  }
end
