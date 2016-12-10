module Fear
  class Success
    include Try
    include Dry::Equalizer(:value)
    include RightBiased::Right

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

    # @return [Success]
    def or_else
      self
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
        fail NoSuchElementError, "Predicate does not hold for `#{value}`"
      end
    rescue => error
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
    rescue => error
      Failure.new(error)
    end

    # @return [Try]
    def flat_map
      super
    rescue => error
      Failure.new(error)
    end

    # @return [Right]
    def to_either
      Right.new(value)
    end
  end
end
