desc "rake task to run course reserves test suite" 

task :ci do |t|
  rm_rf "coverage"
  puts %x[rspec]
  Rake::Task["cucumber"].invoke

end
