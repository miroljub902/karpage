# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[karpage.com www.karpage.com] + [%r{\Ahttp://(karpage\.dev|localhost)(:\d+)?\z}]
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
