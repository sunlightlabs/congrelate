# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activerecord}
  s.version = "2.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{David Heinemeier Hansson}]
  s.autorequire = %q{active_record}
  s.date = %q{2009-11-26}
  s.description = %q{Implements the ActiveRecord pattern (Fowler, PoEAA) for ORM. It ties database tables and classes together for business objects, like Customer or Subscription, that can find, save, and destroy themselves without resorting to manual SQL.}
  s.email = %q{david@loudthinking.com}
  s.extra_rdoc_files = [%q{README}]
  s.files = [%q{README}]
  s.homepage = %q{http://www.rubyonrails.org}
  s.rdoc_options = [%q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{activerecord}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Implements the ActiveRecord pattern for ORM.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 2.3.5"])
    else
      s.add_dependency(%q<activesupport>, ["= 2.3.5"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 2.3.5"])
  end
end
