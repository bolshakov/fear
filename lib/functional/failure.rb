module Functional
  class Failure
    include Try
    include Dry::Equalizer(:value)
    include RightBiased::Left

    def initialize(exception)
      @value = exception
    end

    attr_reader :value
    protected :value

    def success?
      false
    end

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
    # TODO: rename to select
    def detect
      self
    end

    # Applies the given block to exception.
    # This is like `flat_map` for the exception.
    #
    # @yieldparam [Exception]
    # @yieldreturn [Try]
    # @return [Try]
    #
    def recover_with
      yield(value).tap do |result|
        Utils.assert_type!(result, Success, Failure)
      end
    rescue => error
      Failure.new(error)
    end

    # Applies the given block to exception.
    # This is like map for the exception.
    # @return [Try]
    #
    def recover
      Success.new(yield(value))
    rescue => error
      Failure.new(error)
    end
  end
end
