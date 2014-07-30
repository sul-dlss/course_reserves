# config valid only for Capistrano 3.1
lock '3.2.1'

set :rvm_ruby_version, '1.9.3-p448'      # Defaults to: 'default'
set :application, 'course_reserves'
set :repo_url, 'git@github.com:sul-dlss/course_reserves.git'

set :ssh_options, {
  keys: [Capistrano::OneTimeKey.temporary_ssh_private_key_path],
  forward_agent: true,
  auth_methods: %w(publickey password)
}

# Default branch is :master
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/reserves/course_reserves'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/initializers/squash_exceptions.rb config/initializers/environment_specific_settings.rb}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log lib/course_work_xml tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart


end
