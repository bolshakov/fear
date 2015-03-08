require 'concurrent'

module Functional
  class Promise
    def initialize(options = {})
      @result = nil
      @options = options
      @future = Concurrent::Future.new(@options) do
        Try { @result }.flatten
      end
    end

    def completed?
      !@result.nil?
    end

    def future
      Future.new(@future, @options)
    end

    def success(value)
      complete(Success(value))
    end

    def success!(value)
      complete!(Success(value))
    end

    def failure(error)
      complete(Failure(error))
    end

    def failure!(error)
      complete!(Failure(error))
    end

    def complete!(result)
      if complete(result)
        self
      else
        fail IllegalStateException, 'Promise already completed.'
      end
    end

    # Tries to complete the promise with either a value or the exception.
    #
    # @return    If the promise has already been completed returns
    #            `false`, or `true` otherwise.
    #
    def complete(result)
      if completed?
        false
      else
        @result = result
        @future.execute
        true
      end
    end
  end
end
