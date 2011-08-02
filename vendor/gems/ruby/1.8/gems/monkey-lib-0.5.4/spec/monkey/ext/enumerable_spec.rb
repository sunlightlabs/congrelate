require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext::Enumerable do
  describe :construct do
    it "always returns the initial object" do
      obj = Object.new
      (1..100).construct(obj) { "not obj" }.should == obj
    end

    it "allows modifying that object" do
      ("a".."c").construct("result: ") { |a,v| a << v }.should == "result: abc"
    end
  end

  describe :construct_hash do
    it "constructs a hash from given hashes" do
      ("a".."b").construct_hash { |v| { v => v } }.should == { "a" => "a", "b" => "b" }
    end

    it "constructs a hash from given arrays" do
      ("a".."b").construct_hash { |v| [v, v] }.should == { "a" => "a", "b" => "b" }
    end

    it "takes an initial hash" do
      ["a"].construct_hash("b" => "b") { |v| [v, v] }.should == { "a" => "a", "b" => "b" }
    end
  end
end