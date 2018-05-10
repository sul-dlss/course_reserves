# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/passenger'
require 'dlss/capistrano'
require "whenever/capistrano"
require 'capistrano/honeybadger'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
