# frozen_string_literal: true

module Fear
  class Some
    include Option
    include RightBiased::Right
    include SomePatternMatch.mixin

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

    alias :blank? :empty?

    # @return [true]
    def present?
      true
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
        other.map do |x|
          if block_given?
            yield(value, x)
          else
            [value, x]
          end
        end
      else
        raise TypeError, "can't zip with #{other.class}"
      end
    end

    # @return [RightBiased::Left, RightBiased::Right]
    def filter_map(&filter)
      map(&filter).select(&:itself)
    end

    # @return [Array<any>]
    def deconstruct
      [get]
    end
  end
end
