require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Backend do
  it "should preffer backports unless any backend already has been loaded" do
    Monkey::Backend.available_backends.first.should == Monkey::Backend::Backports
  end
end
