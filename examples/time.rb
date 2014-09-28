$LOAD_PATH.unshift 'lib'
require 'trip'

class Phone
  def self.call
    sleep(2)
    'ring ring'
  end
end

trip = Trip.new { Phone.call }
trip.pause? { |e| e.name == 'call' or e.name == 'return' }
t1 = trip.start.created_at
t2 = trip.resume.created_at
puts "it took around #{t2 - t1} seconds"
