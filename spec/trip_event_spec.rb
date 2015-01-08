require_relative 'setup'
describe Trip::Event do
  class Y
    def self.run
      # ..
    end
  end

  describe "#module" do
    it "returns a Module" do
      trip = Trip.new { Y.run }
      event = trip.start
      assert_equal Y, event.module
      trip.stop
    end
  end
end
