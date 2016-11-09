web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q default -q mailers -q image_processing -e production
release: bundle exec rake db:migrate
