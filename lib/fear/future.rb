# frozen_string_literal: true

begin
  require "concurrent"
rescue LoadError
  puts "You must add 'concurrent-ruby' to your Gemfile in order to use Fear::Future"
end

module Fear
  # Asynchronous computations that yield futures are created
  # with the +Fear.future+ call:
  #
  #    success = "Hello"
  #    f = Fear.future { success + ' future!' }
  #    f.on_success do |result|
  #      puts result
  #    end
  #
  # Multiple callbacks may be registered; there is no guarantee
  # that they will be executed in a particular order.
  #
  # The future may contain an exception and this means
  # that the future failed. Futures obtained through combinators
  # have the same error as the future they were obtained from.
  #
  #    f = Fear.future { 5 }
  #    g = Fear.future { 3 }
  #    f.flat_map do |x|
  #      g.map { |y| x + y }
  #    end
  #
  # The same program may be written using +Fear.for+
  #
  #    Fear.for(Fear.future { 5 }, Fear.future { 3 }) do |x, y|
  #      x + y
  #    end
  #
  # Futures use +Concurrent::Promise+ under the hood. +Fear.future+ accepts optional configuration Hash passed
  # directly to underlying promise. For example, run it on custom thread pool.
  #
  #     require 'open-uri'
  #
  #     future = Fear.future(executor: :io) { open('https://example.com/') }
  #
  #     future.map(executor: :fast, &:read).each do |body|
  #       puts "#{body}"
  #     end
  #
  # @see https://github.com/scala/scala/blob/2.11.x/src/library/scala/concurrent/Future.scala
  #
  class Future
    include Awaitable

    # @param promise [nil, Concurrent::Future] converts
    #  +Concurrent::Promise+ into +Fear::Future+.
    # @param options [see Concurrent::Future] options will be passed
    #   directly to +Concurrent::Promise+
    # @yield given block and evaluate it in the future.
    # @api private
    # @see Fear.future
    #
    def initialize(promise = nil, **options, &block)
      if block_given? && promise
        raise ArgumentError, "pass block or promise"
      end

      @options = options
      @promise = promise || Concurrent::Promise.execute(@options) do
        Fear.try(&block)
      end
    end
    attr_reader :promise
    private :promise

    # Calls the provided callback when this future is completed successfully.
    #
    # If the future has already been completed with a value,
    # this will either be applied immediately or be scheduled asynchronously.
    # @yieldparam [any] value
    # @return [self]
    # @see #transform
    #
    # @example
    #   Fear.future { }.on_success do |value|
    #     # ...
    #   end
    #
    def on_success(&block)
      on_complete do |result|
        result.each(&block)
      end
    end

    # When this future is completed successfully match against its result
    #
    # If the future has already been completed with a value,
    # this will either be applied immediately or be scheduled asynchronously.
    # @yieldparam [Fear::PatternMatch] m
    # @return [self]
    #
    # @example
    #   Fear.future { }.on_success_match do |m|
    #     m.case(42) { ... }
    #   end
    #
    def on_success_match
      on_success do |value|
        Fear.matcher { |m| yield(m) }.call_or_else(value, &:itself)
      end
    end

    # When this future is completed with a failure apply the provided callback to the error.
    #
    # If the future has already been completed with a failure,
    # this will either be applied immediately or be scheduled asynchronously.
    #
    # Will not be called in case that the future is completed with a value.
    # @yieldparam [StandardError]
    # @return [self]
    #
    # @example
    #   Fear.future { }.on_failure do |error|
    #     if error.is_a?(HTTPError)
    #       # ...
    #     end
    #   end
    #
    def on_failure
      on_complete do |result|
        if result.failure?
          yield result.exception
        end
      end
    end

    # When this future is completed with a failure match against the error.
    #
    # If the future has already been completed with a failure,
    # this will either be applied immediately or be scheduled asynchronously.
    #
    # Will not be called in case that the future is completed with a value.
    # @yieldparam [Fear::PatternMatch] m
    # @return [self]
    #
    # @example
    #   Fear.future { }.on_failure_match do |m|
    #     m.case(HTTPError) { |error| ... }
    #   end
    #
    def on_failure_match
      on_failure do |error|
        Fear.matcher { |m| yield(m) }.call_or_else(error, &:itself)
      end
    end

    # When this future is completed call the provided block.
    #
    # If the future has already been completed,
    # this will either be applied immediately or be scheduled asynchronously.
    # @yieldparam [Fear::Try]
    # @return [self]
    #
    # @example
    #   Fear.future { }.on_complete do |try|
    #     try.map(&:do_the_job)
    #   end
    #
    def on_complete
      promise.add_observer do |_time, try, _error|
        yield try
      end
      self
    end

    # When this future is completed match against result.
    #
    # If the future has already been completed,
    # this will either be applied immediately or be scheduled asynchronously.
    # @yieldparam [Fear::TryPatternMatch]
    # @return [self]
    #
    # @example
    #   Fear.future { }.on_complete_match do |m|
    #     m.success { |result| }
    #     m.failure { |error| }
    #   end
    #
    def on_complete_match
      promise.add_observer do |_time, try, _error|
        Fear::Try.matcher { |m| yield(m) }.call_or_else(try, &:itself)
      end
      self
    end

    # Returns whether the future has already been completed with
    # a value or an error.
    #
    # @return [true, false] +true+ if the future is already
    #   completed, +false+ otherwise.
    #
    # @example
    #   future = Fear.future { }
    #   future.completed? #=> false
    #   sleep(1)
    #   future.completed? #=> true
    #
    def completed?
      promise.fulfilled?
    end

    # The value of this +Future+.
    #
    # @return [Fear::Option<Fear::Try>] if the future is not completed
    #   the returned value will be +Fear::None+. If the future is
    #   completed the value will be +Fear::Some<Fear::Success>+ if it
    #   contains a valid result, or +Fear::Some<Fear::Failure>+ if it
    #   contains an error.
    #
    def value
      Fear.option(promise.value(0))
    end

    # Asynchronously processes the value in the future once the value
    # becomes available.
    #
    # Will not be called if the future fails.
    # @yieldparam [any] yields with successful feature value
    # @see {#on_complete}
    #
    alias each on_success

    # Creates a new future by applying the +success+ function to the successful
    # result of this future, or the +failure+ function to the failed result.
    # If there is any non-fatal error raised when +success+ or +failure+ is
    # applied, that error will be propagated to the resulting future.
    #
    # @yieldparam success [#get] function that transforms a successful result of the
    #   receiver into a successful result of the returned future
    # @yieldparam failure [#exception] function that transforms a failure of the
    #   receiver into a failure of the returned future
    # @return [Fear::Future] a future that will be completed with the
    #   transformed value
    #
    # @example
    #   Fear.future { open('http://example.com').read }
    #     .transform(
    #        ->(value) { ... },
    #        ->(error) { ... },
    #     )
    #
    def transform(success, failure)
      promise = Promise.new(@options)
      on_complete_match do |m|
        m.success { |value| promise.success(success.(value)) }
        m.failure { |error| promise.failure(failure.(error)) }
      end
      promise.to_future
    end

    # Creates a new future by applying a block to the successful result of
    # this future. If this future is completed with an error then the new
    # future will also contain this error.
    #
    # @return [Fear::Future]
    #
    # @example
    #   future = Fear.future { 2 }
    #   future.map { |v| v * 2 } #=> the same as Fear.future { 2 * 2 }
    #
    def map(&block)
      promise = Promise.new(@options)
      on_complete do |try|
        promise.complete!(try.map(&block))
      end

      promise.to_future
    end

    # Creates a new future by applying a block to the successful result of
    # this future, and returns the result of the function as the new future.
    # If this future is completed with an exception then the new future will
    # also contain this exception.
    #
    # @yieldparam [any]
    # @return [Fear::Future]
    #
    # @example
    #   f1 = Fear.future { 5 }
    #   f2 = Fear.future { 3 }
    #   f1.flat_map do |v1|
    #     f1.map do |v2|
    #       v2 * v1
    #     end
    #   end
    #
    def flat_map
      promise = Promise.new(@options)
      on_complete_match do |m|
        m.case(Fear::Failure) { |failure| promise.complete!(failure) }
        m.success do |value|
          yield(value).on_complete { |callback_result| promise.complete!(callback_result) }
        rescue StandardError => error
          promise.failure!(error)
        end
      end
      promise.to_future
    end

    # Creates a new future by filtering the value of the current future
    # with a predicate.
    #
    # If the current future contains a value which satisfies the predicate,
    # the new future will also hold that value. Otherwise, the resulting
    # future will fail with a +NoSuchElementError+.
    #
    # If the current future fails, then the resulting future also fails.
    #
    # @yieldparam [#get]
    # @return [Fear::Future]
    #
    # @example
    #   f = Fear.future { 5 }
    #   f.select { |value| value % 2 == 1 } # evaluates to 5
    #   f.select { |value| value % 2 == 0 } # fail with NoSuchElementError
    #
    def select
      map do |result|
        if yield(result)
          result
        else
          raise NoSuchElementError, "#select predicate is not satisfied"
        end
      end
    end

    # Creates a new future that will handle any matching error that this
    # future might contain. If there is no match, or if this future contains
    # a valid result then the new future will contain the same.
    #
    # @return [Fear::Future]
    #
    # @example
    #   Fear.future { 6 / 0 }.recover { |error| 0  } # result: 0
    #   Fear.future { 6 / 0 }.recover do |m|
    #     m.case(ZeroDivisionError) { 0 }
    #     m.case(OtherTypeOfError) { |error| ... }
    #   end # result: 0
    #
    #
    def recover(&block)
      promise = Promise.new(@options)
      on_complete do |try|
        promise.complete!(try.recover(&block))
      end

      promise.to_future
    end

    # Zips the values of +self+ and +other+ future, and creates
    # a new future holding the array of their results.
    #
    # If +self+ future fails, the resulting future is failed
    # with the error stored in +self+.
    # Otherwise, if +other+ future fails, the resulting future is failed
    # with the error stored in +other+.
    #
    # @param other [Fear::Future]
    # @return [Fear::Future]
    #
    # @example
    #   future1 = Fear.future { call_service1 }
    #   future1 = Fear.future { call_service2 }
    #   future1.zip(future2) #=> returns the same result as Fear.future { [call_service1, call_service2] },
    #     # but it performs two calls asynchronously
    #
    def zip(other)
      promise = Promise.new(@options)
      on_complete_match do |m|
        m.success do |value|
          other.on_complete do |other_try|
            promise.complete!(
              other_try.map do |other_value|
                if block_given?
                  yield(value, other_value)
                else
                  [value, other_value]
                end
              end,
            )
          end
        end
        m.failure do |error|
          promise.failure!(error)
        end
      end

      promise.to_future
    end

    # Creates a new future which holds the result of +self+ future if it
    # was completed successfully, or, if not, the result of the +fallback+
    # future if +fallback+ is completed successfully.
    # If both futures are failed, the resulting future holds the error
    # object of the first future.
    #
    # @param fallback [Fear::Future]
    # @return [Fear::Future]
    #
    # @example
    #   f = Fear.future { fail 'error' }
    #   g = Fear.future { 5 }
    #   f.fallback_to(g) # evaluates to 5
    #
    def fallback_to(fallback)
      promise = Promise.new(@options)
      on_complete_match do |m|
        m.success { |value| promise.complete!(value) }
        m.failure do |error|
          fallback.on_complete_match do |m2|
            m2.success { |value| promise.complete!(value) }
            m2.failure { promise.failure!(error) }
          end
        end
      end

      promise.to_future
    end

    # Applies the side-effecting block to the result of +self+ future,
    # and returns a new future with the result of this future.
    #
    # This method allows one to enforce that the callbacks are executed in a
    # specified order.
    #
    # @note that if one of the chained +and_then+ callbacks throws
    # an error, that error is not propagated to the subsequent
    # +and_then+ callbacks. Instead, the subsequent +and_then+ callbacks
    # are given the original value of this future.
    #
    # @example The following example prints out +5+:
    #   f = Fear.future { 5 }
    #   f.and_then do
    #     m.success { }fail| 'runtime error' }
    #   end.and_then do |m|
    #     m.success { |value| puts value } # it evaluates this branch
    #     m.failure { |error| puts error.massage }
    #   end
    #
    def and_then
      promise = Promise.new(@options)
      on_complete do |try|
        Fear.try do
          Fear::Try.matcher { |m| yield(m) }.call_or_else(try, &:itself)
        end
        promise.complete!(try)
      end

      promise.to_future
    end

    # @api private
    def __result__(at_most)
      __ready__(at_most).value.get_or_else { raise "promise not completed" }
    end

    # @api private
    def __ready__(at_most)
      if promise.wait(at_most).complete?
        self
      else
        raise Timeout::Error
      end
    end

    class << self
      # Creates an already completed +Future+ with the specified error.
      # @param exception [StandardError]
      # @return [Fear::Future]
      #
      def failed(exception)
        new(executor: Concurrent::ImmediateExecutor.new) do
          raise exception
        end
      end

      # Creates an already completed +Future+ with the specified result.
      # @param result [Object]
      # @return [Fear::Future]
      #
      def successful(result)
        new(executor: Concurrent::ImmediateExecutor.new) do
          result
        end
      end
    end
  end
end
