module Functional
  module Try
    BLOCK_REQUIRED = 'block required'.freeze

    # Returns `true` if the `Try` is a `Failure`, `false` otherwise.
    #
    def failure?
      assert_method_defined!('failure?')
    end

    # Returns `true` if the `Try` is a `Success`, `false` otherwise.
    #
    def success?
      assert_method_defined!('success?')
    end

    # Returns the value from this `Success` or throws the exception if
    # this is a `Failure`.
    #
    def get
      assert_method_defined!('get')
    end

    # Returns the value from this `Success` or the given `default`
    # argument if this is a `Failure`.
    #
    # Note: This will throw an exception if it is not a success and
    # default throws an exception
    #
    def get_or_else(&_default)
      assert_method_defined!('get_or_else')
    end

    # Returns this `Try` if it's a `Success` or the given `default`
    # argument if this is a `Failure`.
    #
    def or_else(&_default)
      assert_method_defined!('or_else')
    end

    # Returns `None` if this is a `Failure` or a `Some` containing the
    # value if this is a `Success`.
    #
    def to_option
      assert_method_defined!('to_option')
    end

    # Transforms a nested `Try`, ie, a `Success` of `Success``,
    # into an un-nested `Try`, ie, a `Success`.
    def flatten
      assert_method_defined!('flatten')
    end

    # Applies the given block if this is a `Success`
    #
    # Note: If `block` throws exception, then this method may throw an exception.
    #
    def each(&_block)
      assert_method_defined!('each')
    end

    # Returns the given function applied to the value from this `Success`
    # or returns this if this is a `Failure`.
    #
    def flat_map(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      map(&block).flatten
    end

    # Maps the given function to the value from this `Success`
    # or returns this if this is a `Failure`.
    #
    def map(&_block)
      assert_method_defined!('map')
    end

    # Converts this to a `Failure` if the predicate
    # is not satisfied.
    #
    def select(&_predicate)
      assert_method_defined!('select')
    end

    private

    def assert_method_defined!(method)
      fail NotImplementedError, "#{self.class.name}##{method}"
    end
  end
end
