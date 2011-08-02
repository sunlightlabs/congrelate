module Monkey
  module Version
    def self.new(value = "")
      super.to_version!
    end

    def to_version
      self.dup
    end

    def to_version!
      self
    end

    def major; fields[0]; end
    def minor; fields[1]; end
    def tiny;  fields[2]; end

    def <=>(other)
      return super unless other.respond_to? :to_version
      mine, others = fields.dup, other.to_version.fields
      loop do
        a, b = mine.unshift, others.unshift
        return  0 if a.nil? and b.nil?
        return  1 if b.nil? or (a.is_a? Integer and b.is_a? String)
        return -1 if a.nil? or (b.is_a? Integer and a.is_a? String)
        return comp unless (comp = (a <=> b)) == 0
      end
    end

    def fields
      split(".").map { |f| f =~ /^\d+$/ ? f.to_i : f }
    end
  end
end