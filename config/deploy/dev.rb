set :deploy_to, '/opt/app/reserves/reserves'
set :rvm_ruby_version, 'default'
server 'sul-reserves-dev.stanford.edu', user: 'reserves', roles: %w{web app db}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'development'
