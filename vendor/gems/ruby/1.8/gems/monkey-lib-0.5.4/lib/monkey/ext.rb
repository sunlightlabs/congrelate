require "pathname"
require "monkey/engine"

module Monkey
  module Ext

    module ExtDSL

      module ClassDsl
        include ExtDSL
        def core_class(klass = nil)
          klass ? @core_class = klass : @core_class
        end
      end

      def core_class(klass = nil)
        if klass
          @core_class = klass
          klass.send :include, self
          self::ExtClassMethods.extend ClassDsl
          self::ExtClassMethods.core_class @core_class
          @core_class.class_eval <<-EOS
            def method_missing(meth, *args, &blk)
              return super if Monkey::Backend.setup?
              Monkey::Backend.setup
              __send__(meth, *args, &blk)
            end
          EOS
          propagate_include
        end
        @core_class
      end

      if Monkey::Engine.jruby? and JRUBY_VERSION < '1.6.0'
        def each_module(&block)
          list = []
          ObjectSpace.each_object(Class) { |c| list << c }
          list.each(&block)
        end
      else
        def each_module(&block)
          ObjectSpace.each_object(Module, &block)
        end
      end

      def propagate_include
        return if core_class.is_a? Class
        each_module do |mod|
          next unless mod < core_class and not mod < self
          mod.send(:include, core_class)
        end
      end

      def included(klass)
        klass.extend self::ExtClassMethods
        super
      end

      def rename_core_method(old_name, new_name)
        core_class.send :undef_method, alias_core_method(old_name, new_name)
      end

      def alias_core_method(old_name, new_name)
        new_name = new_name % old_name if new_name.is_a? String
        core_class.send :alias_method, new_name, old_name
        old_name
      end

      def feature(name, mode = :instance, &block)
        case mode
        when :instance then block.call
        when :class then class_methods(&block)
        when :shared
          feature(name, :instance, &block)
          feature(name, :class, &block)
        else raise ArgumentError, "unkown mode #{mode.inspect}"
        end
      end

      def class_methods(&block)
        self::ExtClassMethods.class_eval(&block)
      end

      def expects(*list)
        list.each do |name|
          Monkey::Ext.expectations[core_class] << name.to_s
        end
      end

    end

    def self.expectations
      @expectations ||= Hash.new { |h,k| h[k] = [] }
    end

    Dir[::File.dirname(__FILE__) + "/ext/*.rb"].sort.each do |path|
      filename   = ::File.basename(path, '.rb')
      class_name = filename.capitalize
      extension  = eval <<-EOS
        module ::Monkey::Ext::#{class_name} # <- for MacRuby!?
          module ExtClassMethods; end          # <- for 1.9
          self
        end
      EOS
      extension.extend ExtDSL
      extension.core_class ::Object.const_get(class_name)
      require "monkey/ext/#{filename}"
    end

  end
end