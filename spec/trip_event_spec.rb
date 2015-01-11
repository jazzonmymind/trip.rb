require_relative 'setup'
describe Trip::Event do
  class Y
    def self.run
      # ..
    end
  end

  let(:trip) do
    Trip.new { Y.run }
  end

  let(:event) do
    trip.start
  end

  after do
    trip.stop
  end

  describe "#module" do
    it "returns a Module" do
      assert_equal Y, event.module
    end
  end

  describe "#file" do
    it "returns __FILE__ from binding" do
      assert_equal __FILE__, event.file
    end
  end

  describe "#lineno" do
    it "returns __LINE__ from binding" do
      assert_equal 4, event.lineno
    end
  end

  describe "#method" do
    it "returns __method__ from binding" do
      assert_equal :run, event.method
    end
  end

  describe "#binding" do
    it "returns a binding" do
      assert_instance_of Binding, event.binding
    end
  end

  describe "#__binding__" do
    it "returns a binding for instance of Trip::Event" do
      assert_equal true, Trip::Event === event.__binding__.eval('self')
    end
  end
end
