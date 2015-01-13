class Trip
  require 'thread'
  require_relative 'trip/event'
  require_relative 'trip/version'

  NotStartedError  = Class.new(RuntimeError)
  NotFinishedError = Class.new(RuntimeError)

  RUN_STATE   = 'run'
  SLEEP_STATE = 'sleep'
  END_STATE   = [nil, false]
  CALL_E      = ['call', 'c-call']
  RETURN_E    = ['return', 'c-return']
  PAUSE_P     = Proc.new { |event|
    CALL_E.include?(event.name) or RETURN_E.include?(event.name)
  }

  #
  #  @param [Proc] &block
  #    a block of code
  #
  #  @return [Trip]
  #    returns an instance of Trip
  #
  def initialize(&block)
    if block.equal?(nil)
      raise ArgumentError, 'no block given'
    end
    @thread = nil
    @block  = block
    @queue  = nil
    @pause  = PAUSE_P
  end

  #
  # @raise [ArgumentError]
  #   when no arguments are received
  #
  # @param [Proc] callable
  #   accepts a Proc or a block
  #
  # @return [Proc]
  #   returns a Proc
  #
  def pause?(callable = nil, &block)
    pause = callable || block
    if pause.equal?(nil)
      raise ArgumentError, 'no block given'
    end
    @pause = pause
  end

  #
  #  @return [Boolean]
  #    returns true when a trace has started
  #
  def started?
    @thread != nil
  end

  #
  #  @return [Boolean]
  #    returns true when a tracer thread is running
  #
  def running?
    @thread and @thread.status == RUN_STATE
  end

  #
  #  @return [Boolean]
  #    returns true when a tracer thread has finished
  #
  def finished?
    @thread and END_STATE.include?(@thread.status)
  end

  #
  #  @return [Boolean]
  #    returns true when a tracer thread is sleeping
  #
  def sleeping?
    @thread and @thread.status == SLEEP_STATE
  end

  #
  #  resume the tracer
  #
  #  @raise [Trip::NotStartedError]
  #    when the start method has not been called yet
  #
  #  @return [Trip::Event, nil]
  #    returns an event or nil
  #
  def resume
    unless started?
      raise NotStartedError, 'trace not started'
    end
    if sleeping?
      @thread.wakeup
      @queue.deq
    end
  end

  #
  # start the tracer
  #
  # @raise [Trip::NotFinishedError]
  #   when a trace is already in progress
  #
  # @return [Trip::Event, nil]
  #   returns an event, or nil
  #
  def start
    if started? and !finished?
      raise NotFinishedError, 'trace not finished'
    end
    @queue = Queue.new
    @thread = Thread.new do
      Thread.current.set_trace_func method(:on_event).to_proc
      @block.call
      Thread.current.set_trace_func(nil)
      @queue.enq(nil)
    end
    @queue.deq
  end

  #
  # stop the tracer
  #
  # @return [nil]
  #   returns nil
  #
  def stop
    if @thread
      @thread.set_trace_func(nil)
      @thread.exit
      @thread.join
      nil
    end
  end

private
  def on_event(name, file, lineno, method, binding, classname)
    event = Event.new name, {
      file:    file,
      lineno:  lineno,
      mod:     classname,
      method:  method,
      binding: binding
    }
    if event.file != __FILE__ and @pause.call(event)
      @queue.enq(event)
      Thread.stop
    end
  rescue Exception => e
    warn <<-CRASH.each_line.map(&:lstrip)
    (trip) the tracer has crashed.

    #{e.class}:
    #{e.message}

    BACKTRACE
    #{e.backtrace.join("\n")}
    CRASH
    Thread.current.set_trace_func(nil)
  end
end
