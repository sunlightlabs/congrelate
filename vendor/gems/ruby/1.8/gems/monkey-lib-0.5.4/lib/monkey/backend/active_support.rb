Monkey::Backend.new :ActiveSupport, :active_support do
  def setup
    load_lib :version
    expects_module "::ActiveSupport::CoreExtensions::String::Inflections" if version < "3"
    load_libs :core_ext => %w[array/extract_options string/inflections module/introspection]
    if version < "3"
      begin
        load_libs "core_ext/object/singleton_class"
      rescue LoadError
        load_libs "core_ext/object/metaclass"
        ::Object.send(:alias_method, :singleton_class, :metaclass)
      end
      load_libs "core_ext/object/misc"
      ::Array.send  :include, ::ActiveSupport::CoreExtensions::Array::ExtractOptions
      ::Module.send :include, ::ActiveSupport::CoreExtensions::Module
      ::String.send :include, ::ActiveSupport::CoreExtensions::String::Inflections
    else
      load_libs "core_ext/kernel/singleton_class"
    end
    ::String.send(:alias_method, :to_const_string, :camelcase)
    ::String.send(:alias_method, :to_const_path, :underscore)
  end

  def version(default = "0")
    load_lib :version
    @version ||= ActiveSupport::VERSION::STRING or super
  rescue NameError
    super
  end
end