class ApplicationMailer
  include Rails.application.routes.url_helpers

  def initialize
    Rails.application.routes.default_url_options[:host] = ENV['HOSTNAME']
  end

  def postmark
    @_postmark ||= Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'])
  end
end
