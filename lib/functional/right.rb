module Functional
  class Right
    include Either
    include RightBiased::Right

    # Returns `Left(default)` if the given predicate
    # does not hold for the right value, otherwise, returns `Right`.
    #
    # @param default [Proc, any]
    # @return [Either]
    #
    def detect(default)
      if yield(value)
        self
      else
        Left.new(Utils.return_or_call_proc(default))
      end
    end

    # @return [Left] value in `Left`
    def swap
      Left.new(value)
    end

    # @param reduce_right [Proc] the function to apply if this is a `Right`
    # @return [any] Applies `reduce_right` to the value.
    #
    def reduce(_, reduce_right)
      reduce_right.call(value)
    end

    # Joins an `Either` through `Right`.
    #
    # This method requires that the right side of this `Either` is itself an
    # Either type.
    #
    # This method, and `join_left`, are analogous to `Option#flatten`
    #
    # @return [Either]
    # @raise [TypeError] if it does not contain `Either`.
    #
    def join_right
      value.tap do |v|
        Utils.assert_type!(v, Either)
      end
    end

    # Joins an `Either` through `Left`.
    #
    # @return [self]
    #
    def join_left
      self
    end
  end
end
