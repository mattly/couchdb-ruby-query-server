require 'rake/testtask'

desc "Run all the tests"
task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false
end
