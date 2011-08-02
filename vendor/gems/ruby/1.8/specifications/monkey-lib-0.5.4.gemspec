# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{monkey-lib}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Konstantin Haase}]
  s.date = %q{2010-09-19}
  s.description = %q{Making ruby extension frameworks pluggable.}
  s.email = %q{konstantin.mailinglists@googlemail.com}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{LICENSE}, %q{lib/monkey/autoloader.rb}, %q{lib/monkey/backend/active_support.rb}, %q{lib/monkey/backend/backports.rb}, %q{lib/monkey/backend/common/extract_options.rb}, %q{lib/monkey/backend/common/parent.rb}, %q{lib/monkey/backend/common/singleton_class.rb}, %q{lib/monkey/backend/common/tap.rb}, %q{lib/monkey/backend/extlib.rb}, %q{lib/monkey/backend/facets.rb}, %q{lib/monkey/backend.rb}, %q{lib/monkey/engine.rb}, %q{lib/monkey/ext/array.rb}, %q{lib/monkey/ext/enumerable.rb}, %q{lib/monkey/ext/file.rb}, %q{lib/monkey/ext/module.rb}, %q{lib/monkey/ext/object.rb}, %q{lib/monkey/ext/pathname.rb}, %q{lib/monkey/ext/string.rb}, %q{lib/monkey/ext/symbol.rb}, %q{lib/monkey/ext.rb}, %q{lib/monkey/hash_fix.rb}, %q{lib/monkey/matcher.rb}, %q{lib/monkey/version.rb}, %q{lib/monkey-lib.rb}, %q{lib/monkey.rb}]
  s.files = [%q{README.rdoc}, %q{LICENSE}, %q{lib/monkey/autoloader.rb}, %q{lib/monkey/backend/active_support.rb}, %q{lib/monkey/backend/backports.rb}, %q{lib/monkey/backend/common/extract_options.rb}, %q{lib/monkey/backend/common/parent.rb}, %q{lib/monkey/backend/common/singleton_class.rb}, %q{lib/monkey/backend/common/tap.rb}, %q{lib/monkey/backend/extlib.rb}, %q{lib/monkey/backend/facets.rb}, %q{lib/monkey/backend.rb}, %q{lib/monkey/engine.rb}, %q{lib/monkey/ext/array.rb}, %q{lib/monkey/ext/enumerable.rb}, %q{lib/monkey/ext/file.rb}, %q{lib/monkey/ext/module.rb}, %q{lib/monkey/ext/object.rb}, %q{lib/monkey/ext/pathname.rb}, %q{lib/monkey/ext/string.rb}, %q{lib/monkey/ext/symbol.rb}, %q{lib/monkey/ext.rb}, %q{lib/monkey/hash_fix.rb}, %q{lib/monkey/matcher.rb}, %q{lib/monkey/version.rb}, %q{lib/monkey-lib.rb}, %q{lib/monkey.rb}]
  s.homepage = %q{http://github.com/rkh/monkey-lib}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Making ruby extension frameworks pluggable.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<backports>, [">= 0"])
    else
      s.add_dependency(%q<backports>, [">= 0"])
    end
  else
    s.add_dependency(%q<backports>, [">= 0"])
  end
end
