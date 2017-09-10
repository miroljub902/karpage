# frozen_string_literal: true

Sidekiq.default_worker_options = {
  unique: :until_and_while_executing,
  unique_args: ->(args) { args.first.except('job_id') }
}

redis_url = ENV['REDIS_URL'].presence || 'redis://localhost:6379/0'

# https://devcenter.heroku.com/articles/forked-pg-connections#sidekiq
Sidekiq.configure_server do |config|
  if (database_url = ENV['DATABASE_URL'])
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{ENV['SIDEKIQ_CONCURRENCY'] || 25}"
    ActiveRecord::Base.establish_connection
  end

  config.redis = { size: (ENV['REDIS_CONNECTIONS'] || 27).to_i, url: redis_url }
end

Sidekiq.configure_client do |config|
  # 1 connection per Rails process
  config.redis = { size: (ENV['REDIS_CLIENT_CONNECTIONS'] || 1).to_i, url: redis_url }
end

SidekiqUniqueJobs.config.unique_args_enabled = true

schedule_file = 'config/schedule.yml'
if File.exists?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
