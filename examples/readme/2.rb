$LOAD_PATH.unshift 'lib'
require 'trip'

class Planet
  def initialize(name)
    @name = name
  end

  def echo
    'ping'
  end
end

trip = Trip.new { Planet.new('earth').echo }
trip.pause? { |e| # pause on a method call
  e.name == 'call'
} 
e1 = trip.start   # Trip::Event (for the method call of `Planet#initialize`)
e2 = trip.resume  # Trip::Event (for the method call of `Planet#echo`)
e3 = trip.resume  # nil         (returns nil, thread exits)

# inspect the events
p e1
p e2
p e3
