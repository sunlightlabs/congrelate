module Monkey
  class Matcher
    def initialize(&block)
      @block = block
    end

    def ===(other)
      @block.call(other)
    end
  end
end
