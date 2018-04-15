# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[beta.karpage.com karpage.com www.karpage.com] + [%r{\Ahttp://localhost:[0-9]+\z}]
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
