# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{httparty}
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{John Nunemaker}]
  s.date = %q{2009-04-23}
  s.description = %q{Makes http fun! Also, makes consuming restful web services dead easy.}
  s.email = %q{nunemaker@gmail.com}
  s.executables = [%q{httparty}]
  s.extra_rdoc_files = [%q{bin/httparty}, %q{lib/httparty/cookie_hash.rb}, %q{lib/httparty/core_extensions.rb}, %q{lib/httparty/exceptions.rb}, %q{lib/httparty/module_inheritable_attributes.rb}, %q{lib/httparty/request.rb}, %q{lib/httparty/response.rb}, %q{lib/httparty/version.rb}, %q{lib/httparty.rb}, %q{README}]
  s.files = [%q{bin/httparty}, %q{lib/httparty/cookie_hash.rb}, %q{lib/httparty/core_extensions.rb}, %q{lib/httparty/exceptions.rb}, %q{lib/httparty/module_inheritable_attributes.rb}, %q{lib/httparty/request.rb}, %q{lib/httparty/response.rb}, %q{lib/httparty/version.rb}, %q{lib/httparty.rb}, %q{README}]
  s.homepage = %q{http://httparty.rubyforge.org}
  s.post_install_message = %q{When you HTTParty, you must party hard!}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Httparty}, %q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{httparty}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Makes http fun! Also, makes consuming restful web services dead easy.}

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<crack>, [">= 0.1.1"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<crack>, [">= 0.1.1"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<crack>, [">= 0.1.1"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
