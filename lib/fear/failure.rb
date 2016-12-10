module Fear
  class Failure
    include Try
    include Dry::Equalizer(:value)
    include RightBiased::Left

    # @param [StandardError]
    def initialize(exception)
      @value = exception
    end

    attr_reader :value
    protected :value

    # @return [Boolean]
    def success?
      false
    end

    # @raise
    def get
      fail value
    end

    # @return [Try] of calling block
    def or_else
      Success.new(yield)
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
      yield(value).tap do |result|
        Utils.assert_type!(result, Success, Failure)
      end
    rescue => error
      Failure.new(error)
    end

    # @yieldparam [Exception]
    # @yieldreturn [any]
    # @return [Try]
    def recover
      Success.new(yield(value))
    rescue => error
      Failure.new(error)
    end
  end
end
