require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Matcher do
  it 'should consider block for #===' do
    matcher = Monkey::Matcher.new { |x| x > 6 }
    (matcher === 5).should be_false
    (matcher === 8).should be_true
  end

  it 'should work with switch' do
    matcher = Monkey::Matcher.new { |x| /foo/ === x }
    case 'foobar'
    when matcher then nil
    else fail 'did not match'
    end
  end
end