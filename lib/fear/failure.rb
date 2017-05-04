module Fear
  class Failure
    include Try
    include Dry::Equalizer(:exception)
    include RightBiased::Left

    # @param [StandardError]
    def initialize(exception)
      @exception = exception
    end

    attr_reader :exception

    # @return [Boolean]
    def success?
      false
    end

    # @return [true]
    def failure?
      true
    end

    # @raise
    def get
      fail exception
    end

    # @return [Try] of calling block
    def or_else(*args)
      super
    rescue => error
      Failure.new(error)
    end

    # @return [Failure] self
    def flatten
      self
    end

    # @return [Failure] self
    def select
      self
    end

    # @yieldparam [Exception]
    # @yieldreturn [Try]
    # @return [Try]
    def recover_with
      yield(exception).tap do |result|
        Utils.assert_type!(result, Success, Failure)
      end
    rescue => error
      Failure.new(error)
    end

    # @yieldparam [Exception]
    # @yieldreturn [any]
    # @return [Try]
    def recover
      Success.new(yield(exception))
    rescue => error
      Failure.new(error)
    end

    # @return [Left]
    def to_either
      Left.new(exception)
    end

    # Used in case statement
    # @param other [any]
    # @return [Boolean]
    def ===(other)
      if other.is_a?(Failure)
        exception === other.exception
      else
        super
      end
    end
  end
end
