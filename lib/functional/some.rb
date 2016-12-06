module Functional
  class Some
    include Option
    include Dry::Equalizer(:get)
    include RightBiased::Right

    attr_reader :value
    protected :value

    def initialize(value)
      @value = value
    end

    # @return option's value
    def get
      @value
    end

    # @return [Option] self if this `Option` is nonempty and
    #   applying the `predicate` to this option's value
    #   returns true. Otherwise, return `None`.
    #
    def detect
      if yield(value)
        self
      else
        None.new
      end
    end

    # @return [Option] if applying the `predicate` to this
    #   option's value returns false. Otherwise, return `None`.
    #
    def reject
      if yield(value)
        None.new
      else
        self
      end
    end
  end
end
