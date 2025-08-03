# frozen_string_literal: true

module Fear
  class Right
    include Either
    include RightBiased::Right
    include PatternMatch.mixin

    # @api private
    def right_value
      value
    end

    # @return [true]
    def right?
      true
    end
    alias_method :success?, :right?

    # @return [false]
    def left?
      false
    end
    alias_method :failure?, :left?

    # @param default [Proc, any]
    # @return [Either]
    def select_or_else(default)
      if yield(value)
        self
      else
        Left.new(Utils.return_or_call_proc(default))
      end
    end

    # @return [Either]
    def select
      if yield(value)
        self
      else
        Left.new(value)
      end
    end

    # @return [Either]
    def reject
      if yield(value)
        Left.new(value)
      else
        self
      end
    end

    # @return [Left] value in `Left`
    def swap
      Left.new(value)
    end

    # @param reduce_right [Proc]
    # @return [any]
    def reduce(_reduce_left, reduce_right)
      reduce_right.call(value)
    end

    # @return [Either]
    # @raise [TypeError]
    def join_right
      value.tap do |v|
        Utils.assert_type!(v, Either)
      end
    end

    # @return [self]
    def join_left
      self
    end
  end
end
