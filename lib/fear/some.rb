# frozen_string_literal: true

module Fear
  class Some
    include Option
    include RightBiased::Right
    include SomePatternMatch.mixin

    EXTRACTOR = proc do |option|
      if Fear::Some === option
        Fear.some([option.get])
      else
        Fear.none
      end
    end

    attr_reader :value
    protected :value

    def initialize(value)
      @value = value
    end

    # @return [any]
    def get
      @value
    end

    # @return [any]
    def or_nil
      @value
    end

    # @return [false]
    def empty?
      false
    end

    # @return [Option]
    def select
      if yield(value)
        self
      else
        None
      end
    end

    # @return [Option]
    def reject
      if yield(value)
        None
      else
        self
      end
    end

    # @param other [Any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(Some) && get == other.get
    end

    # @return [String]
    def inspect
      "#<Fear::Some get=#{value.inspect}>"
    end

    # @return [String]
    alias to_s inspect

    # @param other [Fear::Option]
    # @return [Fear::Option]
    def zip(other)
      if other.is_a?(Option)
        other.map { |x| [value, x].freeze }
      else
        raise TypeError, "can't zip with #{other.class}"
      end
    end
  end
end
