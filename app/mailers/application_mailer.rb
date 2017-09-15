# frozen_string_literal: true

class ApplicationMailer
  include Rails.application.routes.url_helpers

  def initialize
    Rails.application.routes.default_url_options[:host] = ENV['HOSTNAME']
  end

  def postmark
    @_postmark ||= Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'])
  end

  private

  def handle_invalid_recipient(_user)
    begin
      yield
    rescue Postmark::InvalidMessageError => e
      # https://postmarkapp.com/developer/api/overview
      case e.error_code
      when 406 # Inactive recipient
        # TODO?
      end
    end
  end
end
