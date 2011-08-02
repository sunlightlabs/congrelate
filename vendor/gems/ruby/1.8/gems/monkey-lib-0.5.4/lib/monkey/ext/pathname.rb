require "pathname"

module Monkey
  module Ext
    module Pathname
      ##
      # @return [Pathname, NilClass] Path with correct casing.
      def cased_path
        return unless exist?
        return Dir.chdir(self) { Pathname(Dir.pwd) } if ::File.directory? path
        files = Dir.chdir(dirname) { Dir.entries('.').select { |f| f.downcase == basename.to_s.downcase } }
        dirname.cased_path.join(files.size == 1 ? files.first : basename)
      end
      
      def chdir(&block)
        Dir.chdir(self.to_s, &block)
      end
      
      def open(mode = "r", &block)
        File.open(self, mode, &block)
      end
      
    end
  end
end
