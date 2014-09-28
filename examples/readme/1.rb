$LOAD_PATH.unshift 'lib'
require 'trip'

def add(x,y)
  x + y
end

trip = Trip.new { add(20,50) }
e1 = trip.start  # Trip::Event (for the method call of "#add")
e2 = trip.resume # Trip::Event (for the method return of "#add")
e3 = trip.resume # nil         (returns nil, thread exits)

# inspect the event objects
p e1
p e2
p e3
