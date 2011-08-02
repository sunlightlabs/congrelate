require 'monkey/engine'
Hash.class_eval { def hash; to_a.hash end } if Monkey::Engine.mri? and RUBY_VERSION < '1.8.7'
