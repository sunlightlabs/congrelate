module Monkey
  module Backend
    module Common
      module Parent
        ::Module.send :include, self
        def parent
          name && name =~ /^(.+)::[^:]+$/ ? $1.constantize : Object
        end
      end
    end
  end
end