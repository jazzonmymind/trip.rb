class Trip::Event < BasicObject
  Kernel  = ::Kernel
  Time    = ::Time
  CALLS   = %w(call c-call)
  RETURNS = %w(return c-return)

  attr_reader :name, :created_at

  def initialize(name, event)
    @name = name
    @created_at = Time.now
    @event = event
  end

  [:file, :lineno, :module, :method, :binding].each do |name|
    define_method(name) { @event[name] }
  end

  #
  # @return [Binding]
  #   returns a binding for an instance of {Trip::Event}
  #
  def __binding__
    Kernel.binding
  end

  def inspect
    inspect_m = Kernel.instance_method(:inspect).bind(self)
    inspect_m.call
  end
end
