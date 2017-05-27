require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

task :worker do
  set :domain, 'worker.karpage.deploy'
  set :branch, 'production'
end

task :www do
  set :domain, 'app.karpage.deploy'
  set :branch, 'production'
end

task :staging do
  set :domain, 'beta.karpage.com'
  set :branch, 'master'
end

set :deploy_to, '/home/deploy/karpage'
set :repository, 'git@bitbucket.org:paxx/karpage.git'

set :user, 'deploy'
set :forward_agent, true

set :shared_files, fetch(:shared_files, []).push('.env.production')

set :rbenv_path, '/usr/local/rbenv'

task :environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        command %{sudo systemctl restart karpage.target}
      end
    end
  end

  run :local do
    comment 'Notify Appsignal'
    puts `bin/rake deploy:notify_appsignal`
  end
end
