module Monkey
  module Ext
    module Enumerable
      def construct(obj)
        enum_for :construct, obj unless block_given? or !respond_to? :enum_for
        inject(obj) { |a,v| a.tap { yield(a, v) } }
      end

      def construct_hash(default = {})
        enum_for :construct_hash unless block_given? or !respond_to? :enum_for
        construct(default.to_hash.dup) do |h,v|
          result = yield(v)
          result = [result, nil] unless result.is_a? Enumerable
          result = [result] unless result.respond_to? :to_ary
          h.merge! Hash[*result]
        end
      end
    end
  end
end
