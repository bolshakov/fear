# frozen_string_literal: true

module Fear
  class Left
    include Either
    include RightBiased::Left
    include LeftPatternMatch.mixin

    # @api private
    def left_value
      value
    end

    # @return [false]
    def right?
      false
    end
    alias success? right?

    # @return [true]
    def left?
      true
    end
    alias failure? left?

    # @return [Either]
    def select_or_else(*)
      self
    end

    # @return [Left]
    def select
      self
    end

    # @return [Left]
    def reject
      self
    end

    # @return [Right] value in `Right`
    def swap
      Right.new(value)
    end

    # @param reduce_left [Proc]
    # @return [any]
    def reduce(reduce_left, _reduce_right)
      reduce_left.(value)
    end

    # @return [self]
    def join_right
      self
    end

    # @return [Either]
    # @raise [TypeError]
    def join_left
      value.tap do |v|
        Utils.assert_type!(v, Either)
      end
    end

    # Used in case statement
    # @param other [any]
    # @return [Boolean]
    def ===(other)
      if other.is_a?(Left)
        value === other.value
      else
        super
      end
    end
  end
end
