# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couchdb-ruby}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Lyon"]
  s.date = %q{2010-03-13}
  s.description = %q{A Ruby version of the CouchDB query server. Allows you to write your map/reduce and other functions in ruby instead of javascript or erlang.
}
  s.email = %q{matt@flowerpowered.com}
  s.files = ["LICENSE", "README.md", "Rakefile", "bin/couchdb_view_server", "couchdb-ruby.gemspec", "lib/couch_db.rb", "lib/couch_db/design.rb", "lib/couch_db/sandbox.rb", "lib/couch_db/view.rb", "test/sandbox_test.rb", "test/test_helper.rb", "test/view_test.rb"]
  s.homepage = %q{http://github.com/mattly/couchdb-ruby-query-server}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{couchdb-ruby-query-server}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{a Ruby interpreter for the CouchDB Query server.}
  s.test_files = ["test/sandbox_test.rb", "test/view_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end
