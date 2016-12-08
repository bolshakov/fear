module Fear
  class Left
    include Either
    include RightBiased::Left

    # Returns `Left` or `default`.
    #
    # @param default [Proc, any]
    # @return [Either]
    #
    def detect(default)
      Left.new(Utils.return_or_call_proc(default))
    end

    # @return [Right] value in `Right`
    #
    def swap
      Right.new(value)
    end

    # @param reduce_left [Proc] the function to apply if this is a `Left`
    # @return [any] Applies `reduce_left` to the value.
    #
    def reduce(reduce_left, _)
      reduce_left.call(value)
    end

    # Joins an `Either` through `Right`.
    #
    # @return [self]
    #
    def join_right
      self
    end

    # Joins an `Either` through `Left`.
    #
    # This method requires that the left side of this `Either` is itself an
    # Either type.
    #
    # This method, and `join_right`, are analogous to `Option#flatten`
    #
    # @return [Either]
    # @raise [TypeError] if it does not contain `Either`.
    #
    def join_left
      value.tap do |v|
        Utils.assert_type!(v, Either)
      end
    end
  end
end
