require_relative 'setup'
describe Trip do
  class Planet
    def echo(message)
      return message
    end
  end

  before do
    @planet = Planet.new
    @trip   = Trip.new { @planet.echo('ping') }
  end

  after do
    unless @trip.finished?
      @trip.stop
    end
  end

  describe '#initialize' do
    it 'raises an ArgumentError without a block' do
      assert_raises(ArgumentError) { Trip.new }
    end
  end

  describe '#start' do
    it 'returns an instance of Trip::Event' do
      assert Trip::Event === @trip.start
    end

    it 'returns nil with a false pause predicate' do
      @trip.pause? { false }
      assert_equal nil, @trip.start
    end

    it 'raises Trip::NotFinishedError' do
      @trip.start
      assert_raises(Trip::NotFinishedError) { @trip.start }
    end
  end

  describe '#sleeping?' do
    it 'returns true' do
      @trip.start
      assert_equal true, @trip.sleeping?
    end

    it 'returns false' do
      @trip.start
      @trip.resume while @trip.resume
      assert_equal false, @trip.sleeping?
    end
  end

  describe '#started?' do
    it 'returns true' do
      @trip.start
      assert_equal true, @trip.started?
    end

    it 'returns false' do
      assert_equal false, @trip.started?
    end
  end
  
  describe '#resume' do
    it 'raises Trip::NotStartedError' do
      assert_raises(Trip::NotStartedError) { @trip.resume }
    end
  end

  describe '#pause?' do
    it 'raises an ArgumentError' do
      assert_raises(ArgumentError) { @trip.pause? }
    end
    
    it 'accepts a Proc' do
      obj = Proc.new {}
      assert_equal obj, @trip.pause?(obj)
    end
  end

  describe '#finished?' do
    it 'returns true' do
      @trip.start
      @trip.resume while @trip.resume
      assert_equal true, @trip.finished?
    end

    it 'returns false' do
      @trip.start
      assert_equal false, @trip.finished? 
    end

    it 'returns nil' do
      assert_equal nil, @trip.finished?
    end
  end

  describe '#running?' do
    it 'returns false' do
      @trip.start
      @trip.resume while @trip.resume
      assert_equal false, @trip.running?
    end

    it 'returns nil' do
      assert_equal nil, @trip.running?
    end
  end

  describe Trip::Event do
    describe '#module' do
      it 'returns a Module' do
        e1 = @trip.start
        assert_equal Planet, e1.module
      end
    end

    describe '#method' do
      it 'returns a method name' do
        e1 = @trip.start
        assert_equal :echo, e1.method
      end
    end

    describe '#file' do
      it 'returns a path' do
        e1 = @trip.start
        assert_equal __FILE__, e1.file
      end
    end

    describe '#lineno' do
      it 'returns an Integer' do
        e1 = @trip.start
        assert_kind_of Integer, e1.lineno
      end
    end

    describe '#binding' do
      it 'returns a Binding with access to the local variable "message"' do 
        @trip.pause? { |e| e.name == 'call' or e.name == 'return' }
        e1 = @trip.start
        e2 = @trip.resume
        assert_equal 'ping', e2.binding.eval('message')
      end
    end

    describe '#__binding__' do
      it 'returns a Binding for an instance of Trip::Event' do
        e1 = @trip.start
        assert Trip::Event === e1.__binding__.eval('self')
      end
    end
  end
end
