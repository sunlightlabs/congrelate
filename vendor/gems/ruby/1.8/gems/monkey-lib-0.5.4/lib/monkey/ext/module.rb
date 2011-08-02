module Monkey
  module Ext
    module Module
      # Defined by backend.
      expects :parent

      def nested_method_missing(mod, name, *args, &block)
        Monkey.invisible __FILE__ do
          if respond_to? :parent and parent != self
            parent.send(:nested_method_missing, mod, name, *args, &block)
          else
            mod.send(:method_missing_without_nesting, name, *args) 
          end
        end
      end

      def method_missing(name, *args, &block)
        if respond_to? :parent and parent.respond_to? :nested_method_missing
          parent.nested_method_missing(self, name, *args, &block)
        else
          method_missing_without_nesting(name, *args, &block)
        end
      end

    end
  end
end

