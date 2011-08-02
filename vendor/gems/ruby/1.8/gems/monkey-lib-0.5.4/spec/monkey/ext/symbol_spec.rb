require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext::Symbol do
  describe '~@' do
    it 'should match objects responding to a method' do
      matcher = ~:foo
      o = Object.new
      (matcher === o).should be_false
      o.stub! :foo
      (matcher === o).should be_true
    end

    it 'should work for case statements' do
      case 'foo'
      when ~:to_s then nil
      else fail 'did not match'
      end
    end
  end
end
