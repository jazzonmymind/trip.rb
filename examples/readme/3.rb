$LOAD_PATH.unshift 'lib'
require 'trip'

def add(x,y)
  x + y
end

trip = Trip.new { add(2,3) }
e1 = trip.start             # Trip::Event (for the method call of add)
x  = e1.binding.eval('x')   # returns 2   (x is equal to 2)
trip.stop                   # thread exits

puts "x is equal to #{x}"
