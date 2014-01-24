require 'yaml'

config = YAML.load_file('config/config.yml')['deployment'] || {}

require 'bundler/capistrano'

set :stages, config['stages'] || []
set :default_stage, config['default_stage'] || (config['stages'] || []).first
require 'capistrano/ext/multistage'

set :application, 'RoomReservation'
set :repository, config['repository']
set :user, config['user']
set :default_environment, config['default_environment'] || {}
default_run_options[:pty] = true
set :scm, :git
set :branch, config['branch']
set :deploy_via, :remote_cache
set :deploy_to, config['deploy_to']
set :use_sudo, false
set :keep_releases, 5
set :shared_children, shared_children + %w{pids sockets tmp public/uploads}

# if you want to clean up old releases on each deploy uncomment this:
after 'deploy:restart', 'deploy:cleanup'

after 'deploy:finalize_update', 'deploy:symlink_config'
after 'deploy:update_code', 'deploy:migrate'
after 'deploy:restart', 'deploy:cleanup'
after 'deploy:restart', 'roomreservation:clear_cache'
after 'roomreservation:clear_cache', 'roomreservation:warm_cache'

namespace :deploy do
  desc "Symlinks required configuration files"
  task :symlink_config, :roles => :app do
    %w{config.yml unicorn.rb god.conf thin.yml sidekiq.yml}.each do |config_file|
      run "ln -nfs #{deploy_to}/shared/config/#{config_file} #{release_path}/config/#{config_file}"
    end
  end
end

namespace :roomreservation do
  desc "Clears Cache"
  task :clear_cache, :roles => :app do
    run "cd #{release_path} && rbenv exec bundle exec rake roomreservation:clear_cache"
  end
  desc "Warms Cache"
  task :warm_cache, :roles => :app do
    run "cd #{release_path} && rbenv exec bundle exec rake roomreservation:warm_cache"
  end
end