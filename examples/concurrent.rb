$LOAD_PATH.unshift 'lib'
require 'trip'

#
# an example method.
# it assigns a local variable and returns control to the caller.
#
def example
  x = 1
end

#
# initialize Trip with a block that calls the example() method.
# the trace doesn't start yet.
#
trip = Trip.new do 
  example()
end

#
# the tracer can be paused on certain events.
#
trip.pause? do |event| 
  event.name == 'call' or event.name == 'return' 
end

#
# start trip.
# e1 and e2 reference Trip::Event objects. e3 ends up referencing nil.
# nil is returned when trip has finished.
#
e1 = trip.start  # before assignment of 'x'
e2 = trip.resume # after assignment of 'x'
e3 = trip.resume # finished

#
# print the value of 'x'.
# the local variable 'x' belongs to the binding closed over by e2(method return).
#
print 'x is equal to "%s".' % e2.binding.eval('x')

