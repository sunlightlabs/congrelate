require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext::Module do
  describe "backend expectations" do
    # expects :parent
    it "imports parent from backend" do
      Monkey::Ext::Module.parent.should == Monkey::Ext
      Monkey::Ext.parent.should == Monkey
      Monkey.parent.should == Object
      Object.parent.should == Object
      Object.send :remove_const, :ExtFoo if Object.const_defined? :ExtFoo
      ExtFoo = Monkey::Ext::Module
      ExtFoo.parent.should == Monkey::Ext
    end
  end

  describe "nested_method_missing" do

    before do
      [:Foo, :Bar, :Blah].inject(Object) do |parent, name|
        parent.send :remove_const, name if parent.const_defined? name
        parent.const_set name, Module.new
      end
    end

    it "should call nested_method_missing on parent" do
      Foo.should_receive(:nested_method_missing).once.with(Foo::Bar, :foo)
      Foo::Bar.foo
    end

  end
end
