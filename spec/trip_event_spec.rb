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

  describe '#name' do
    describe 'call and return from a method implemented in Ruby' do
      it 'returns "call"' do
        e = trip.start
        assert_equal 'call', e.name
      end

      it 'returns "return"' do
        trip.start
        e = trip.resume
        assert_equal 'return', e.name
      end
    end

    describe 'call and return from a method implemented in C' do
      let(:trip) do
        Trip.new { Kernel.print '' }.tap do |trip|
          trip.pause? { |e| e.module == Kernel and e.method == :print }
        end
      end

      it 'returns "c-call"' do
        e = trip.start
        assert_equal 'c-call', e.name
      end

      it 'returns "c-return"' do
        trip.start
        e = trip.resume
        assert_equal 'c-return', e.name
      end
    end
  end

  describe '#created_at' do
    it 'returns a Time' do
      assert_instance_of Time, event.created_at
    end
  end

  describe '#module' do
    it 'returns a Module' do
      assert_equal Y, event.module
    end
  end

  describe '#file' do
    it 'returns __FILE__ from binding' do
      assert_equal __FILE__, event.file
    end
  end

  describe '#lineno' do
    it 'returns __LINE__ from binding' do
      assert_equal 4, event.lineno
    end
  end

  describe '#method' do
    it 'returns __method__ from binding' do
      assert_equal :run, event.method
    end
  end

  describe '#binding' do
    it 'returns a binding' do
      assert_instance_of Binding, event.binding
    end
  end

  describe '#__binding__' do
    it 'returns a binding for instance of Trip::Event' do
      assert_equal true, Trip::Event === event.__binding__.eval('self')
    end
  end
end
