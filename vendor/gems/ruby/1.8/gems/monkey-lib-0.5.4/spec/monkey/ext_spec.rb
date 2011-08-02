require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext do
  describe Monkey::Ext::ExtDSL do

    before do
      @core_class = Class.new
      @extension = Module.new
      @extension::ExtClassMethods = Module.new
      @extension.extend Monkey::Ext::ExtDSL
      @extension.core_class @core_class
    end

    it "extends the core class" do
      @core_class.ancestors.should include(@extension)
    end

    it "adds methods to the core class instances" do
      instance = @core_class.new
      @extension.class_eval do
        def foo
          42
        end
      end
      instance.foo.should == 42
    end

    it "adds methods to the core class" do
      @extension.class_methods do
        def foo
          42
        end
      end
      @core_class.foo.should == 42
    end

    it "is able to rename core instance methods" do
      instance = @core_class.new
      @core_class.class_eval do
        def foo
          42
        end
      end
      @extension.rename_core_method :foo, :bar
      instance.should_not respond_to(:foo)
      instance.bar.should == 42
    end

  end
end
