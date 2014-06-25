begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'rspec rake task not available (rspec not installed)'
  task :rspec do
    abort 'Rspec rake task is not available. Be sure to install rspec as a gem or plugin'
  end
end

task :default => :spec
