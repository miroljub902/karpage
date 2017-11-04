Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[karpage.com www.karpage.com karpage.dev:3000 localhost:3000]
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
