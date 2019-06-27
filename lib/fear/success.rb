module Fear
  class Success
    include Try
    include RightBiased::Right
    include SuccessPatternMatch.mixin

    EXTRACTOR = proc do |try|
      if Fear::Success === try
        Fear.some([try.get])
      else
        Fear.none
      end
    end

    attr_reader :value
    protected :value

    # @param [any]
    def initialize(value)
      @value = value
    end

    # @return [any]
    def get
      @value
    end

    # @return [Boolean]
    def success?
      true
    end

    # @return [false]
    def failure?
      false
    end

    # @return [Try]
    def flatten
      if value.is_a?(Try)
        value.flatten
      else
        self
      end
    end

    # @yieldparam [any] value
    # @yieldreturn [Boolean]
    # @return [Try]
    def select
      if yield(value)
        self
      else
        raise NoSuchElementError, "Predicate does not hold for `#{value}`"
      end
    rescue StandardError => error
      Failure.new(error)
    end

    # @return [Success]
    def recover_with
      self
    end

    # @return [Success]
    def recover
      self
    end

    # @return [Try]
    def map
      super
    rescue StandardError => error
      Failure.new(error)
    end

    # @return [Try]
    def flat_map
      super
    rescue StandardError => error
      Failure.new(error)
    end

    # @return [Right]
    def to_either
      Right.new(value)
    end

    # @param other [Any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(Success) && value == other.value
    end

    # @return [String]
    def inspect
      "#<Fear::Success value=#{value.inspect}>"
    end

    # @return [String]
    alias to_s inspect
  end
end
