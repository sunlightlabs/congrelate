require __FILE__.sub(%r{monkey/.*$}, "spec_helper")

describe Monkey::Ext::String do

  describe "backend expectations" do

    # expects :constantize :underscore, :camelcase
    it "imports constantize from backend" do
      "Object".constantize.should == Object
      "Monkey::Ext".constantize.should == Monkey::Ext
    end

    # expects :to_const_string
    it "imports to_const_string from backend" do
      "object".to_const_string.should == "Object"
      "monkey/ext".to_const_string.should == "Monkey::Ext"
    end

    # expects :to_const_path
    it "imports to_const_path from backend" do
      "Object".to_const_path.should == "object"
      "Monkey::Ext".to_const_path.should == "monkey/ext"
    end

    # expects :underscore
    it "imports underscore from backend" do
      "FooBar".underscore.should == "foo_bar"
    end

    # expects :camelcase
    it "imports camelcase from backend" do
      ["FooBar", "fooBar"].should include("foo_bar".camelcase)
    end

  end

  describe "like Pathname" do

    before do
      @strings = ["/usr/bin/ruby", ".", "..", ENV["HOME"]]
    end

    it "imports Pathname's cleanpath to String" do
      @strings.each do |s|
        s.cleanpath.should == Pathname(s).cleanpath.to_s
      end
    end

    it "imports Pathname's realpath to String" do
      @strings.each do |s|
        begin
          s.realpath.should == Pathname(s).realpath.to_s
        rescue Errno::ENOENT
        end
      end
    end

    it "imports Pathname's mountpoint? to String" do
      @strings.each do |s|
        s.mountpoint?.should == Pathname(s).mountpoint?
      end
    end

    it "imports Pathname's root? to String" do
      @strings.each do |s|
        s.root?.should == Pathname(s).root?
      end
    end

    it "imports Pathname's absolute_path? to String" do
      @strings.each do |s|
        s.absolute_path?.should == Pathname(s).absolute?
      end
    end

    it "imports Pathname's file_relative? to String" do
      @strings.each do |s|
        s.file_relative?.should == Pathname(s).relative?
      end
    end

    it "imports Pathname's file_join to String" do
      @strings.each do |s|
        s.file_join("foo").should == Pathname(s).join("foo").to_s
        s.file_join(:foo).should == Pathname(s).join("foo").to_s
      end
    end

    it "imports Pathname's atime to String" do
      @strings.each do |s|
        s.atime.should == Pathname(s).atime
      end
    end

    it "imports Pathname's ctime to String" do
      @strings.each do |s|
        s.ctime.should == Pathname(s).ctime
      end
    end

    it "imports Pathname's mtime to String" do
      @strings.each do |s|
        s.mtime.should == Pathname(s).mtime
      end
    end    

    it "imports Pathname's ftype to String" do
      @strings.each do |s|
        s.ftype.should == Pathname(s).ftype.to_s
      end
    end

    it "imports Pathname's basename to String" do
      @strings.each do |s|
        s.basename.should == Pathname(s).basename.to_s
      end
    end

    it "imports Pathname's dirname to String" do
      @strings.each do |s|
        s.dirname.should == Pathname(s).dirname.to_s
      end
    end

    it "imports Pathname's extname to String" do
      @strings.each do |s|
        s.extname.should == Pathname(s).extname.to_s
      end
    end

    it "imports Pathname's expand_path to String" do
      @strings.each do |s|
        s.expand_path.should == Pathname(s).expand_path.to_s
      end
    end

    it "imports Pathname's blockdev? to String" do
      @strings.each do |s|
        s.blockdev?.should == Pathname(s).blockdev?
      end
    end

    it "imports Pathname's chardev? to String" do
      @strings.each do |s|
        s.chardev?.should == Pathname(s).chardev?
      end
    end

    it "imports Pathname's file_executable? to String" do
      @strings.each do |s|
        s.file_executable?.should == Pathname(s).executable?
      end
    end

    it "imports Pathname's file_executable_real? to String" do
      @strings.each do |s|
        s.file_executable_real?.should == Pathname(s).executable_real?
      end
    end

    it "imports Pathname's atime to String" do
      @strings.each do |s|
        s.atime.should == Pathname(s).atime
      end
    end

    it "imports Pathname's ctime to String" do
      @strings.each do |s|
        s.ctime.should == Pathname(s).ctime
      end
    end

    it "imports Pathname's mtime to String" do
      @strings.each do |s|
        s.mtime.should == Pathname(s).mtime
      end
    end    

    it "imports Pathname's ftype to String" do
      @strings.each do |s|
        s.ftype.should == Pathname(s).ftype.to_s
      end
    end

    it "imports Pathname's basename to String" do
      @strings.each do |s|
        s.basename.should == Pathname(s).basename.to_s
      end
    end

    it "imports Pathname's dirname to String" do
      @strings.each do |s|
        s.dirname.should == Pathname(s).dirname.to_s
      end
    end

    it "imports Pathname's extname to String" do
      @strings.each do |s|
        s.extname.should == Pathname(s).extname.to_s
      end
    end

    it "imports Pathname's expand_path to String" do
      @strings.each do |s|
        s.expand_path.should == Pathname(s).expand_path.to_s
      end
    end

    it "imports Pathname's blockdev? to String" do
      @strings.each do |s|
        s.blockdev?.should == Pathname(s).blockdev?
      end
    end

    it "imports Pathname's chardev? to String" do
      @strings.each do |s|
        s.chardev?.should == Pathname(s).chardev?
      end
    end

    it "imports Pathname's file_executable? to String" do
      @strings.each do |s|
        s.file_executable?.should == Pathname(s).executable?
      end
    end

    it "imports Pathname's file_executable_real? to String" do
      @strings.each do |s|
        s.file_executable_real?.should == Pathname(s).executable_real?
      end
    end

    it "imports Pathname's directory? to String" do
      @strings.each do |s|
        s.directory?.should == Pathname(s).directory?
      end
    end

    it "imports Pathname's file? to String" do
      @strings.each do |s|
        s.file?.should == Pathname(s).file?
      end
    end

    it "imports Pathname's pipe? to String" do
      @strings.each do |s|
        s.pipe?.should == Pathname(s).pipe?
      end
    end

    it "imports Pathname's socket? to String" do
      @strings.each do |s|
        s.socket?.should == Pathname(s).socket?
      end
    end

    it "imports Pathname's file_owned? to String" do
      @strings.each do |s|
        s.file_owned?.should == Pathname(s).owned?
      end
    end

    it "imports Pathname's file_readable? to String" do
      @strings.each do |s|
        s.file_readable?.should == Pathname(s).readable?
      end
    end

    it "imports Pathname's file_readable_real? to String" do
      @strings.each do |s|
        s.file_readable_real?.should == Pathname(s).readable_real?
      end
    end

    it "imports Pathname's symlink? to String" do
      @strings.each do |s|
        s.symlink?.should == Pathname(s).symlink?
      end
    end

    it "imports Pathname's file_writable? to String" do
      @strings.each do |s|
        s.file_writable?.should == Pathname(s).writable?
      end
    end

    it "imports Pathname's file_writable_real? to String" do
      @strings.each do |s|
        s.file_writable_real?.should == Pathname(s).writable_real?
      end
    end

    it "imports Pathname's file_zero? to String" do
      @strings.each do |s|
        s.file_zero?.should == Pathname(s).zero?
      end
    end

    it "imports Pathname's file_exist? to String" do
      @strings.each do |s|
        s.file_exist?.should == Pathname(s).exist?
        s.file_exists?.should == Pathname(s).exist? 
      end
    end

    it "imports Pathname's file_grpowned? to String" do
      @strings.each do |s|
        s.file_grpowned?.should == Pathname(s).grpowned?
      end
    end

    it "imports Pathname's file_size? to String" do
      @strings.each do |s|
        s.file_size?.should == Pathname(s).size?
      end
    end

    it "imports Pathname's file_sticky? to String" do
      @strings.each do |s|
        s.file_sticky?.should == Pathname(s).sticky?
      end
    end

    it "imports Pathname's directory_children to String" do
      @strings.each do |s|
        s.directory_children.should == Pathname(s).children if s.directory?
      end
    end

  end

end