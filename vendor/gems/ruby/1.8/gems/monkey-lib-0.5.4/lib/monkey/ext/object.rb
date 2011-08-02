module Monkey
  module Ext
    module Object

      # Defined by backend.
      expects :singleton_class, :tap

      # Behaves like instance_eval or yield depending on whether a block takes an argument or not.
      #
      #   class Foo
      #     define_method(:foo) { 42 }
      #   end
      #
      #   Foo.new.instance_yield { foo }        # => 42
      #   Foo.new.instance_yield { |c| c.foo }  # => 42
      #
      # Also, you can pass a proc directly:
      #
      #   block = proc { }
      #   instance_yield(block)
      def instance_yield(block = nil, &alternate_block)
        raise ArgumentError, "too many blocks given" if block && alternate_block
        block ||= alternate_block
        raise LocalJumpError, "no block given (yield)" unless block
        block.arity > 0 ? yield(self) : instance_eval(&block)
      end

      def singleton_class_eval(&block)
        singleton_class.class_eval(&block)
      end

      def define_singleton_method(name, &block)
        singleton_class_eval { define_method(name, &block) }
      end

      def metaclass
        warn "DEPRECATION WARNING: #metaclass will be removed, use #singleton_class (#{caller})"
        singleton_class
      end

      def metaclass_eval(&block)
        warn "DEPRECATION WARNING: #metaclass_eval will be removed, use #singleton_class_eval (#{caller})"
        singleton_class_eval(&block)
      end

      alias_core_method :method_missing, :method_missing_without_nesting

    end
  end
end