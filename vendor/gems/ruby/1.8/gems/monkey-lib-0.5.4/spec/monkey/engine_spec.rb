require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Engine do

  it "defines RUBY_VERSION" do
    defined?(RUBY_VERSION).should == "constant"
  end

  it "defines RUBY_ENGINE_VERSION" do
    defined?(RUBY_ENGINE_VERSION).should == "constant"
  end

  it "defines RUBY_DESCRIPTION" do
    defined?(RUBY_DESCRIPTION).should == "constant"
  end

  it "defines REAL_RUBY_VERSION" do
    defined?(RUBY_VERSION).should == "constant"
  end

  it "defines REAL_RUBY_ENGINE_VERSION" do
    defined?(RUBY_ENGINE_VERSION).should == "constant"
  end

  describe "with_ruby_engine" do

    it "sets RUBY_ENGINE and RUBY_ENGINE_VERSION" do
      Monkey::Engine.with_ruby_engine("jruby", "1.4.0") do
        RUBY_ENGINE.should == "jruby"
        RUBY_ENGINE_VERSION.should == "1.4.0"
        Monkey::Engine.should be_jruby
      end
      Monkey::Engine.with_ruby_engine("ruby", "1.8.7") do
        RUBY_ENGINE.should == "ruby"
        RUBY_ENGINE_VERSION.should == "1.8.7"
        Monkey::Engine.should be_mri
      end
    end

    it "restores old RUBY_ENGINE if block given" do
      old = RUBY_ENGINE
      Monkey::Engine.with_ruby_engine("foobar", "1.0") { }
      RUBY_ENGINE.should_not == "foobar"
      RUBY_ENGINE.should == old
    end

    it "restores old RUBY_ENGINE_VERSION if block given" do
      old = RUBY_ENGINE_VERSION
      Monkey::Engine.with_ruby_engine("foobar", "1.0") { }
      RUBY_ENGINE_VERSION.should == old
    end

  end

end