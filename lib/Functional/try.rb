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
    def get_or_else(default)
      if success?
        get
      else
        default
      end
    end

    # Returns this `Try` if it's a `Success` or the given `default`
    # argument if this is a `Failure`.
    #
    def or_else(default)
      fail ArgumentError, 'default should be Try' unless default.is_a?(Try)

      if success?
        self
      else
        default
      end
    end

    # Returns `None` if this is a `Failure` or a `Some` containing the
    # value if this is a `Success`.
    #
    def to_option
      if success?
        Some(get)
      else
        None()
      end
    end

    # Applies the given block if this is a `Success`
    #
    # Note: If `block` throws exception, then this method may throw an exception.
    #
    def each(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if success?
        block.call(get)
      end
      nil
    end

    # Returns the given function applied to the value from this `Success`
    # or returns this if this is a `Failure`.
    #
    def flat_map(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if success?
        Try { block.call(value) }
      else
        self
      end
    end

    alias_method :map, :flat_map

    # Converts this to a `Failure` if the predicate
    # is not satisfied.
    #
    def select(&predicate)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if success?
        Try do
          if predicate.call(value)
            value
          else
            fail "Predicate does not hold for #{value}"
          end
        end
      else
        self
      end
    end

    private

    def assert_method_defined!(method)
      fail NotImplementedError, "#{self.class.name}##{method}"
    end
  end
end
