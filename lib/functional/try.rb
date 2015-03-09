module Functional
  module Try
    BLOCK_REQUIRED = 'block required'.freeze

    # Returns `true` if the `Try` is a `Success`, `false` otherwise.
    #
    def success?
      assert_method_defined!('success?')
    end

    # Returns `true` if the `Try` is a `Failure`, `false` otherwise.
    #
    def failure?
      !success?
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
    def get_or_else(&default)
      if success?
        get
      else
        default.call
      end
    end

    # Returns this `Try` if it's a `Success` or the given `default`
    # argument if this is a `Failure`.
    #
    def or_else(&default)
      if success?
        self
      else
        Try { default.call }.flatten
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

    # Transforms a nested `Try`, ie, a `Success` of `Success``,
    # into an un-nested `Try`, ie, a `Success`.
    #
    def flatten
      if success? && get.is_a?(Try)
        get.flatten
      else
        self
      end
    end

    # Applies the given block if this is a `Success`
    #
    # Note: If `block` throws exception, then this method may
    # throw an exception.
    #
    def each(&block)
      block.call(get) if success?
      self
    end

    # Returns the given function applied to the value from this `Success`
    # or returns this if this is a `Failure`.
    #
    def flat_map(&block)
      map(&block).flatten
    end

    # Maps the given function to the value from this `Success`
    # or returns this if this is a `Failure`.
    #
    def map(&block)
      if success?
        Try { block.call(get) }
      else
        self
      end
    end

    # Converts this to a `Failure` if the predicate
    # is not satisfied.
    #
    def select(&predicate)
      return self if failure?
      Try do
        if predicate.call(get)
          get
        else
          fail "Predicate does not hold for #{get}"
        end
      end
    end

    # Applies the given `block` if this is a `Failure`,
    # otherwise returns this if this is a `Success`.
    # This is like `flat_map` for the exception.
    #
    def recover_with(&block)
      if success?
        self
      else
        recover(&block).flatten
      end
    end

    # Applies the given `block` if this is a `Failure`,
    # otherwise returns this if this is a `Success`.
    # This is like map for the exception.
    #
    def recover(&block)
      if success?
        self
      else
        Try { block.call(exception) }
      end
    end

    private

    def assert_method_defined!(method)
      fail NotImplementedError, "#{self.class.name}##{method}"
    end
  end
end
