require __FILE__.sub(%r{monkey_spec\.rb$}, "spec_helper")

describe Monkey do
  describe :invisible do
    it "removes lines from a backtrace" do
      Monkey.hide_invisibles! do
        begin
          Monkey.invisible(__FILE__) { raise }
        rescue
          $!.backtrace.each do |line|
            line.should_not include(__FILE__)
          end
        end
      end
    end
  end

  if BACKEND
    describe "backend" do
      it "uses backend #{ENV['BACKEND']}" do
        Monkey.backend.should == Monkey::Backend.detect_backend(BACKEND)
      end
    end
  end
end