# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra}
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Blake Mizerany}, %q{Ryan Tomayko}, %q{Simon Rozet}]
  s.date = %q{2010-03-23}
  s.description = %q{Classy web-development dressed in a DSL}
  s.email = %q{sinatrarb@googlegroups.com}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{LICENSE}]
  s.files = [%q{README.rdoc}, %q{LICENSE}]
  s.homepage = %q{http://sinatra.rubyforge.org}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Sinatra}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{sinatra}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Classy web-development dressed in a DSL}

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
      s.add_development_dependency(%q<shotgun>, ["< 1.0", ">= 0.6"])
      s.add_development_dependency(%q<rack-test>, [">= 0.3.0"])
      s.add_development_dependency(%q<haml>, [">= 0"])
      s.add_development_dependency(%q<builder>, [">= 0"])
      s.add_development_dependency(%q<erubis>, [">= 0"])
      s.add_development_dependency(%q<less>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
      s.add_dependency(%q<shotgun>, ["< 1.0", ">= 0.6"])
      s.add_dependency(%q<rack-test>, [">= 0.3.0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<erubis>, [">= 0"])
      s.add_dependency(%q<less>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
    s.add_dependency(%q<shotgun>, ["< 1.0", ">= 0.6"])
    s.add_dependency(%q<rack-test>, [">= 0.3.0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<erubis>, [">= 0"])
    s.add_dependency(%q<less>, [">= 0"])
  end
end
