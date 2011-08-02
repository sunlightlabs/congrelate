# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sunlight}
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Luigi Montanez}]
  s.date = %q{2009-10-30}
  s.description = %q{Library for accessing the Sunlight Labs API.}
  s.email = %q{luigi@sunlightfoundation.com}
  s.homepage = %q{http://github.com/sunlightlabs/ruby-sunlightapi/}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{sunlight}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Library for accessing the Sunlight Labs API.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<ym4r>, [">= 0.6.1"])
    else
      s.add_dependency(%q<json>, [">= 1.1.3"])
      s.add_dependency(%q<ym4r>, [">= 0.6.1"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.1.3"])
    s.add_dependency(%q<ym4r>, [">= 0.6.1"])
  end
end
