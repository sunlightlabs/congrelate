module Monkey
  module Backend
    module Common
      module SingletonClass
        ::Object.send :include, self
        def singleton_class
          class << self
            self
          end
        end
      end
    end
  end
end