Monkey::Backend.new :Facets do
  def setup
    load_libs :kernel => [:meta_class, :constant], :string => [:camelcase, :snakecase]
    # Actually, facets has Kernel#tap, but it behaves different if the block takes no argument.
    missing :tap, :extract_options, :parent
    ::String.class_eval do
      def constantize
        constant to_const_string
      end
      alias to_const_string upper_camelcase
      alias to_const_path snakecase
      alias underscore snakecase
    end
    ::Object.class_eval do
      alias singleton_class meta_class unless respond_to? :singleton_class
    end
  end
end