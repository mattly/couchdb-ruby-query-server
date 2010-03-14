require 'rake/testtask'

desc "Run all the tests"
task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false
end

begin
  require 'rubygems'
rescue LoadError
  # Too bad.
else
  task "couchdb-ruby.gemspec" do
    spec = Gem::Specification.new do |s|
      s.name            = "couchdb-ruby"
      s.version         = "0.1"
      s.platform        = Gem::Platform::RUBY
      s.summary         = "a Ruby interpreter for the CouchDB Query server."
      
      s.description     = <<-EOF
A Ruby version of the CouchDB query server. Allows you to write your map/reduce and other functions in ruby instead of javascript or erlang.
      EOF

      s.files           = `git ls-files`.split("\n")
      s.require_path    = 'lib'
      s.has_rdoc        = false
      s.test_files      = Dir['test/*_test.rb']
      
      s.authors         = ['Matthew Lyon']
      s.email           = 'matt@flowerpowered.com'
      s.homepage        = 'http://github.com/mattly/couchdb-ruby-query-server'
      s.rubyforge_project = 'couchdb-ruby-query-server'
      
      s.add_dependency 'json'
    end

    File.open("couchdb-ruby.gemspec", "w") { |f| f << spec.to_ruby }
  end

  task :gem => ["couchdb-ruby.gemspec"] do
    sh "gem build couchdb-ruby.gemspec"
  end
end