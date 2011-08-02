module Monkey
  module Backend

    @available_backends = []

    class << self
      attr_reader :available_backends, :backend
    end

    module AbstractBackend
      attr_accessor :backend_name, :backend_path

      def available?
        return true if Object.const_defined? backend_name
        $LOADED_FEATURES.any? do |f|
          f =~ /^(.*lib\/)?#{backend_path}|#{backend_path}(-[^\/]+)?\/lib/
        end
      end

      def setup_complete
        require backend_path
        setup
      end

      def load_libs(*data)
        load_with_prefix backend_path, data
      end

      alias load_lib load_libs

      def load_with_prefix(prefix, libs = nil)
        case libs
        when String, Symbol then require File.join(prefix.to_s, libs.to_s)
        when Array then libs.each { |lib| load_with_prefix prefix, lib }
        when Hash then libs.each { |k, v| load_with_prefix File.join(prefix.to_s, k.to_s), v }
        else raise ArgumentError, "cannot handle #{libs.inspect}"
        end
      end

      def missing(*libs)
        load_with_prefix "monkey/backend/common", libs
      end

      def expects_module(name)
        name.split("::").inject(Object) do |parent, name|
          if name.empty?
            parent
          else
            parent.class_eval "module #{name}; self; end"
          end
        end
      end

      def version(default = "0")
        return version(nil) || default unless default.nil?
        return @version if @version
        return unless defined? Gem
        Gem.send :attr_accessor, :loaded_specs
        return unless Gem.loaded_specs.respond_to? :[]
        @version = Gem.loaded_specs[gem_name].version.to_s if Gem.loaded_specs.include? gem_name
      end

      def version!
        version(nil) or raise RuntimeError, "unable to determine backend version"
      end

      def version?
        !!version(false)
      end

      def gem_name
        @gem_name ||= name[/[^:]*$/].downcase
      end

    end

    def self.new(backend_name, backend_path = nil, &block)
      mod = eval "module #{backend_name}; self; end"
      mod.extend AbstractBackend
      backend_path ||= backend_name.to_s.downcase
      mod.backend_name, mod.backend_path = backend_name.to_s, backend_path.to_s
      available_backends << mod
      if block
        eigenclass = class << mod; self; end
        eigenclass.class_eval(&block)
      end
      mod
    end

    def self.preferred_backend
      available_backends.detect { |b| b.available? } || @backend
    end

    def self.setup?
      !!@setup
    end

    def self.setup!(backend)
      if backend
        @setup = true
        @backend = detect_backend(backend)
        @backend.setup
        @backend
      else
        available_backends.each do |backend|
          begin
            return setup!(backend)
          rescue LoadError => error
            @load_error ||= error
            @backend = nil
          end
        end  
        raise @load_error
      end
    end

    class << self
      alias backend= setup!
    end

    def self.setup
      setup! preferred_backend unless setup?
    end

    def self.detect_backend(backend_or_name)
      return backend_or_name if backend_or_name.respond_to? :setup
      detected = available_backends.detect do |backend|
        [backend.backend_name.to_s, backend.backend_path.to_s, backend.name.to_s].include? backend_or_name.to_s
      end
      raise ArgumentError, "cannot detect backend #{backend_or_name.inspect}" unless detected
      detected
    end

    require "monkey/backend/backports"
    require "monkey/backend/active_support"
    require "monkey/backend/facets"
    require "monkey/backend/extlib"

  end
end
