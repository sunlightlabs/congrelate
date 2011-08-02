require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext::Array do
  describe "backend expectations" do
    # expects :extract_options!
    it "imports extract_options! from backend" do
      [:foo, {:x => 10}].extract_options!.should == {:x => 10}
      [:foo].extract_options!.should == {}
      [{:x => 10}, :foo].extract_options!.should == {}
      ary1 = [:foo, {:x => 10}]
      ary1.extract_options!
      ary1.should == [:foo]
      ary2 = [{:x => 10}, :foo]
      ary2.extract_options!
      ary2.should == [{:x => 10}, :foo]
    end
  end

  describe "select!" do
    it "results in the same arrays as Array#select" do
      ([1, 2, 3, 4, 5, 6].select! { |e| e > 3 }).should == ([1, 2, 3, 4, 5, 6].select { |e| e > 3 })
      ([1, 2, 3, 4, 5, 6].select! { |e| e < 0 }).should == ([1, 2, 3, 4, 5, 6].select { |e| e < 0 })
    end

    it "modifies the current array, rather than returning a new one" do
      x = [1, 2, 3, 4, 5, 6]
      x.select! { |e| e > 3 }
      x.should == [4, 5, 6]
    end
  end

  describe '+@' do
    it 'returns a set' do
      (+[1,2]).should be_a(Set)
    end
  end
end