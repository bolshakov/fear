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
      other.is_a?(Failure) && exception == other.exception
    end

    def get_or_else(&default)
      default.call
    end

    def or_else(&default)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      Try { default.call }.flatten
    end

    def to_option
      None()
    end

    def flatten
      self
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

    def recover_with(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      recover(&block).flatten
    end

    def recover(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      Try { block.call(exception) }
    end
  end
end
