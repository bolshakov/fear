module Functional
  class Failure
    include Try

    def initialize(exception)
      @exception = exception
    end

    attr_reader :exception
    protected :exception

    def failure?
      true
    end

    def success?
      false
    end

    def get
      fail exception
    end

    def ==(other)
      self.exception == other.exception
    end

    def get_or_else(default)
      default
    end

    def or_else(default)
      fail ArgumentError, 'default should be Try' unless default.is_a?(Try)

      default
    end

    def to_option
      None()
    end

    def each(&_block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?
    end

    def flat_map(&_block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      self
    end

    def map(&_block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      self
    end

    def select(&_predicate)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      self
    end
  end
end
