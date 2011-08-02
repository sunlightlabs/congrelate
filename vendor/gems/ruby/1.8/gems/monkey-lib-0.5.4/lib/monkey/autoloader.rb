require "monkey-lib"

Module.class_eval do
  alias const_missing_without_detection const_missing

  def const_missing(const_name)
    if respond_to? :parent and parent.autoloader? and not is_a? Monkey::Autoloader
      extend Monkey::Autoloader
      const_missing const_name
    else
      Monkey.invisible(__FILE__) { const_missing_without_detection const_name }
    end
  end

  def autoloader?
    is_a? Monkey::Autoloader or (respond_to? :parent and parent != self and parent.autoloader?)
  end
end

module Monkey
  module Autoloader
    def const_missing(const_name)
      const_name = const_name.to_s
      file = File.join(self.name.to_const_path, const_name.to_const_path)
      begin
        require file
        if const_defined? const_name
          const = const_get const_name
          const.extend Monkey::Autoloader
          const
        else
          warn "expected #{file} to define #{name}::#{const_name}"
          raise LoadError
        end
      rescue LoadError => error
        begin
          return parent.const_get(const_name) if respond_to? :parent and parent != self
        rescue NameError
        end
        warn "tried to load #{file}: #{error.message}"
        super
      end
    end
  end
end