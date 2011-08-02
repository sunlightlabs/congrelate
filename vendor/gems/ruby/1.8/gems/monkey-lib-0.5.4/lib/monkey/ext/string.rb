require "pathname"

module Monkey
  module Ext
    module String
      # Defined by backend.
      expects :constantize, :to_const_string, :to_const_path, :underscore, :camelcase

      feature :version do
        def to_version
          dup.to_version!
        end

        def to_version!
          extend Monkey::Version
          self
        end
      end

      feature :pathname do
        def atime
          Pathname(self).atime
        end

        def absolute_path?
          Pathname(self).absolute?
        end

        def basename
          Pathname(self).basename.to_s
        end

        def blockdev?
          Pathname(self).blockdev?
        end

        def chardev?
          Pathname(self).chardev?
        end

        def cleanpath
          Pathname(self).cleanpath.to_s
        end

        def ctime
          Pathname(self).ctime
        end

        def directory_children
          Pathname(self).children
        end

        def directory?
          Pathname(self).directory?
        end

        def dirname
          Pathname(self).dirname.to_s
        end

        def cased_path
          Pathname(self).cased_path.to_s
        end

        def chdir(&block)
          Pathname(self).chdir(&block)
        end

        def expand_path
          Pathname(self).expand_path.to_s
        end

        def extname
          Pathname(self).extname.to_s
        end

        def file?
          Pathname(self).file?
        end

        def file_exist?
          Pathname(self).exist?
        end

        alias file_exists? file_exist?

        def file_grpowned?
          Pathname(self).grpowned?
        end

        def file_owned?
          Pathname(self).owned?
        end

        def file_size?
          Pathname(self).size?
        end

        def file_sticky?
          Pathname(self).sticky?
        end

        def file_executable?
          Pathname(self).executable?
        end

        def file_executable_real?
          Pathname(self).executable_real?
        end

        def file_join(other)
          Pathname(self).join(other.to_s).to_s
        end

        alias / file_join

        def file_open(mode = 'r', &block)
          Pathname(self).open(mode = 'r', &block)
        end

        def file_readable?
          Pathname(self).readable?
        end

        def file_readable_real?
          Pathname(self).readable_real?
        end

        def file_relative?
          Pathname(self).relative?
        end

        def file_writable?
          Pathname(self).writable?
        end

        def file_writable_real?
          Pathname(self).writable_real?
        end

        def file_zero?
          Pathname(self).zero?
        end

        def ftype
          Pathname(self).ftype.to_s
        end

        def mountpoint?
          Pathname(self).mountpoint?
        end

        def mtime
          Pathname(self).mtime
        end

        def pipe?
          Pathname(self).pipe?
        end

        def realpath
          Pathname(self).realpath.to_s
        end

        def root?
          Pathname(self).root?
        end

        def socket?
          Pathname(self).socket?
        end

        def symlink?
          Pathname(self).symlink?
        end
      end
    end
  end
end