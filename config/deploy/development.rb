server 'sul-reserves-dev.stanford.edu', user: 'reserves', roles: %w{web app db}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "development"
