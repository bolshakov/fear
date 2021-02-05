# frozen_string_literal: true

begin
  require "concurrent"
rescue LoadError
  puts "You must add 'concurrent-ruby' to your Gemfile in order to use Fear::Future"
end

require "fear/try"

module Fear
  # @api private
  class Promise < Concurrent::IVar
    # @param options [Hash] options passed to underlying +Concurrent::Promise+
    def initialize(*_, **options)
      super()
      @options = options
      @promise = Concurrent::Promise.new(options) do
        Fear.try { value }.flatten
      end
    end
    attr_reader :promise, :options
    private :promise
    private :options

    def completed?
      complete?
    end

    # @return [Fear::Future]
    def to_future
      Future.new(promise, **options)
    end

    # Complete this promise with successful result
    # @param value [any]
    # @return [Boolean]
    # @see #complete
    def success(value)
      complete(Fear.success(value))
    end

    # Complete this promise with value
    # @param value [any]
    # @return [self]
    # @raise [IllegalStateException]
    # @see #complete!
    def success!(value)
      complete!(Fear.success(value))
    end

    # Complete this promise with failure
    # @param error [StandardError]
    # @return [Boolean]
    # @see #complete
    def failure(error)
      complete(Fear.failure(error))
    end

    # Complete this promise with failure
    # @param error [StandardError]
    # @return [self]
    # @raise [IllegalStateException]
    # @see #complete!
    def failure!(error)
      complete!(Fear.failure(error))
    end

    # Complete this promise with result
    # @param result [Fear::Try]
    # @return [self]
    # @raise [IllegalStateException] if promise already completed
    def complete!(result)
      if complete(result)
        self
      else
        raise IllegalStateException, "Promise already completed."
      end
    end

    # Complete this promise with result
    # @param result [Fear::Try]
    # @return [Boolean] If the promise has already been completed returns
    #   `false`, or `true` otherwise.
    # @raise [IllegalStateException] if promise already completed
    #
    def complete(result)
      if completed?
        false
      else
        set result
        promise.execute
        true
      end
    end
  end
end
