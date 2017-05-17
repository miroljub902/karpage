# This is a Procfile for Heroku's staging env, so no image processing worker
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 5 -q default -q mailers -e production
release: bundle exec rake db:migrate
