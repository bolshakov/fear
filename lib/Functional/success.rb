module Functional
  class Success
    include Try

    def initialize(value)
      @value = value
    end

    attr_reader :value
    protected :value

    def failure?
      false
    end

    def success?
      true
    end

    def get
      value
    end

    def ==(other)
      other.is_a?(Success) && self.value == other.value
    end

    def get_or_else(_default)
      get
    end

    def or_else(_default)
      fail ArgumentError, 'default should be Try' unless _default.is_a?(Try)

      self
    end

    def to_option
      Some(get)
    end

    def flatten
      if self.value.is_a?(Try)
        self.value.flatten
      else
        self
      end
    end

    def each(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      block.call(get)
      nil
    end

    def flat_map(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      Try { block.call(value) }
    end

    def map(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      Try { block.call(value) }
    end

    def select(&predicate)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      Try do
        if predicate.call(value)
          value
        else
          fail "Predicate does not hold for #{value}"
        end
      end
    end
  end
end
