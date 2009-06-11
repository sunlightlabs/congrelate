module Daywalker
  
  class DynamicFinderMatch # :nodoc:
    attr_accessor :finder, :attribute_names
    def initialize(method)
      case method.to_s
       when /^(unique|all)_by_([_a-zA-Z]\w*)$/
         @finder = $1.to_sym
         @attribute_names = $2.split('_and_').map {|each| each.to_sym}
      end
    end

    def match?
      @attribute_names && @attribute_names.all? do |each|
        Daywalker::Legislator::VALID_ATTRIBUTES.include? each
      end
    end
  end
end
