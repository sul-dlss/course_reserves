desc "rake task to run course reserves test suite" 

task :ci do |t|

  puts %x[rspec]
  Rake::Task["cucumber"].invoke

end
