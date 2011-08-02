module Monkey
  module Backend
    module Common
      module ExtractOptions
        ::Array.send :include, self
        def extract_options!
          last.is_a?(::Hash) ? pop : {}
        end
      end
    end
  end
end
