# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{crack}
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{John Nunemaker}, %q{Wynn Netherland}]
  s.date = %q{2010-07-07}
  s.email = %q{nunemaker@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.rdoc}]
  s.files = [%q{LICENSE}, %q{README.rdoc}]
  s.homepage = %q{http://github.com/jnunemaker/crack}
  s.rdoc_options = [%q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{crack}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Really simple JSON and XML parsing, ripped from Merb and Rails.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
