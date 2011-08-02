module Monkey
  module Ext
    module Symbol
      def ~@
        Monkey::Matcher.new do |obj|
          obj.respond_to?(self)
        end
      end
    end
  end
end