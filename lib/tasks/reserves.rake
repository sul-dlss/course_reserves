desc "Run rspec tests and report coverage statistics."
  namespace :ci do
    Rake::Task["spec"].invoke
    Rake::Task["cucumber"].invoke
  end
