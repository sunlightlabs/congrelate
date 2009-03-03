require 'sunlight'
include Sunlight

configure do
  Sunlight.api_key = 'sunlight9'
  SENATORS = Legislator.all_where :title => 'Sen'
  REPS = Legislator.all_where :title => 'Rep'
end