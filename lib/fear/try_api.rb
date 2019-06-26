# typed: false
module Fear
  module TryApi
    # Constructs a +Try+ using the block. This
    # method ensures any non-fatal exception is caught and a
    # +Failure+ object is returned.
    # @return [Fear::Try]
    # @example
    #   Fear.try { 4/0 } #=> #<Fear::Failure exception=#<ZeroDivisionError: divided by 0>>
    #   Fear.try { 4/2 } #=> #<Fear::Success value=2>
    #
    def try
      success(yield)
    rescue StandardError => error
      failure(error)
    end

    # @param exception [StandardError]
    # @return [Fear::Failure]
    #
    def failure(exception)
      Fear::Failure.new(exception)
    end

    # @param value [any]
    # @return [Fear::Success]
    #
    def success(value)
      Fear::Success.new(value)
    end
  end
end
