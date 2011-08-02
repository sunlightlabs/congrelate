module Monkey

  # Makes sure we always have RUBY_ENGINE, RUBY_ENGINE_VERSION and RUBY_DESCRIPTION
  # TODO: Check IronRuby version detection.
  module Engine

    def jruby?;    RUBY_ENGINE == "jruby";    end
    def mri?;      RUBY_ENGINE == "ruby";     end
    def rbx?;      RUBY_ENGINE == "rbx";      end
    def ironruby?; RUBY_ENGINE == "ironruby"; end
    def macruby?;  RUBY_ENGINE == "macruby";  end
    def maglev?;   RUBY_ENGINE == "maglev";   end

    alias rubinius? rbx?

    def ree?
      !!(RUBY_DESCRIPTION =~ /Ruby Enterprise Edition/) || RUBY_ENGINE == "ree"
    end

    module_function :jruby?
    module_function :mri?
    module_function :rbx?
    module_function :rubinius?
    module_function :ironruby?
    module_function :macruby?
    module_function :maglev?
    module_function :ree?

    def ruby_core?
      maglev? or rubinius?
    end

    module_function :ruby_core?

    include Rubinius if defined? Rubinius

    unless defined? RUBY_ENGINE
      if    defined? JRUBY_VERSION then ::RUBY_ENGINE = "jruby"
      elsif defined? Rubinius      then ::RUBY_ENGINE = "rbx"
      elsif defined? NSObject      then ::RUBY_ENINGE = "macruby"
      elsif defined? Maglev        then ::RUBY_ENINGE = "maglev"
      else                              ::RUBY_ENGINE = "ruby"
      end
    end

    unless RUBY_ENGINE.frozen?
      RUBY_ENGINE.replace "rbx" if RUBY_ENGINE == "rubinius"
      RUBY_ENGINE.downcase!
      RUBY_ENGINE.freeze
    end

    unless defined? RUBY_ENGINE_VERSION
      begin
        # ruby, jruby, macruby, some rubinius versions
        ::RUBY_ENGINE_VERSION = const_get("#{RUBY_ENGINE.upcase}_VERSION")
      rescue NameError
        # maglev, some rubinius versions
        ::RUBY_ENGINE_VERSION = const_get("VERSION")
      end
    end

    unless defined? RUBY_DESCRIPTION
      ::RUBY_DESCRIPTION = "#{RUBY_ENGINE} #{RUBY_ENGINE_VERSION} "
      unless RUBY_ENGINE == "ruby"
        ::RUBY_DESCRIPTION << "(ruby #{RUBY_VERSION}"
        ::RUBY_DESCRIPTION << " patchlevel #{RUBY_PATCHLEVEL}" if defined? RUBY_PATCHLEVEL
        ::RUBY_DESCRIPTION << ") "
      end
      if defined? RUBY_RELEASE_DATE
        ::RUBY_DESCRIPTION << "("
        ::RUBY_DESCRIPTION << BUILDREV[0..8] << " " if defined? BUILDREV
        ::RUBY_DESCRIPTION << RUBY_RELEASE_DATE << ") "
      end
      ::RUBY_DESCRIPTION << "[#{RUBY_PLATFORM}]"
    end

    if ree?
      ::REAL_RUBY_ENGINE_VERSION = ::REE_VERSION = RUBY_DESCRIPTION[/[^ ]+$/]
      ::REAL_RUBY_ENGINE = "ree"
    else
      ::REAL_RUBY_ENGINE, ::REAL_RUBY_ENGINE_VERSION = ::RUBY_ENGINE, ::RUBY_ENGINE_VERSION
    end

    def ruby_engine(engine = RUBY_ENGINE, pretty = true)
      return engine unless pretty
      case engine
      when "ruby"   then ree? ? "Ruby Enterprise Edition" : "Ruby"
      when "ree"    then "Ruby Enterprise Edition"
      when "rbx"    then "Rubinius"
      when "maglev" then "MagLev"
      else engine.capitalize.gsub("ruby", "Ruby")
      end
    end

    module_function :ruby_engine
    
    def self.set_engine(engine, engine_version = nil)
      Object.send :remove_const, "RUBY_ENGINE"
      Object.const_set "RUBY_ENGINE", engine
      if engine_version
        Object.send :remove_const, "RUBY_ENGINE_VERSION"
        Object.const_set "RUBY_ENGINE_VERSION", engine_version
      end
    end

    def with_ruby_engine(engine, engine_version)
      engine_was, engine_version_was = ::RUBY_ENGINE, ::RUBY_ENGINE_VERSION
      unless defined? ::OLD_RUBY_ENGINE
        Object.const_set("OLD_RUBY_ENGINE", ::RUBY_ENGINE)
        Object.const_set("OLD_RUBY_ENGINE_VERSION", ::RUBY_ENGINE_VERSION)
      end
      Monkey::Engine.set_engine engine, engine_version
      if block_given?
        result = yield
        Monkey::Engine.set_engine engine_was, engine_version_was
        result
      else
        [engine_was, engine_version_was]
      end
    end

    module_function :with_ruby_engine

    def use_real_ruby_engine(&block)
      with_ruby_engine(::REAL_RUBY_ENGINE, ::REAL_RUBY_ENGINE_VERSION, &block)
    end

    module_function :use_real_ruby_engine

    def use_original_ruby_engine(&block)
      if defined? ::OLD_RUBY_ENGINE then with_ruby_engine(::OLD_RUBY_ENGINE, ::OLD_RUBY_ENGINE_VERSION, &block)
      else with_ruby_engine(::RUBY_ENGINE, ::RUBY_ENGINE_VERSION, &block)
      end
    end

    module_function :use_original_ruby_engine

  end
end