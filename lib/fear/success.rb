module Fear
  class Success
    include Try
    include Dry::Equalizer(:value)
    include RightBiased::Right

    attr_reader :value
    protected :value

    def initialize(value)
      @value = value
    end

    def get
      @value
    end

    def success?
      true
    end

    # @return [Success] self
    def or_else
      self
    end

    # Transforms a nested `Try`, ie, a `Success` of `Success``,
    # into an un-nested `Try`, ie, a `Success`.
    # @return [Try]
    #
    def flatten
      if value.is_a?(Try)
        value.flatten
      else
        self
      end
    end

    # Converts this to a `Failure` if the predicate
    # is not satisfied.
    # @yieldparam [any] value
    # @yieldreturn [Boolean]
    # @return [Try]
    #
    def select
      if yield(value)
        self
      else
        fail NoSuchElementError, "Predicate does not hold for `#{value}`"
      end
    rescue => error
      Failure.new(error)
    end

    # @return [Success] self
    #
    def recover_with
      self
    end

    # @return [Success] self
    #
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
  end
end
