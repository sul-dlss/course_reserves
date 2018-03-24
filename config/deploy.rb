set :application, 'course_reserves'
set :repo_url, 'git@github.com:sul-dlss/course_reserves.git'

set :ssh_options, {
  keys: [Capistrano::OneTimeKey.temporary_ssh_private_key_path],
  forward_agent: true,
  auth_methods: %w(publickey password)
}

# Default branch is :master
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/app/reserves/reserves'

set :honeybadger_env, fetch(:stage)

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/honeybadger.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log config/settings lib/course_work_xml tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
