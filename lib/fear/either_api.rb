# frozen_string_literal: true

module Fear
  module EitherApi
    # @param value [Object]
    # @return [Fear::Left]
    # @example
    #   Fear.left(42) #=> #<Fear::Left value=42>
    #
    def left(value)
      Fear::Left.new(value)
    end

    # @param value [Object]
    # @return [Fear::Right]
    # @example
    #   Fear.right(42) #=> #<Fear::Right value=42>
    #
    def right(value)
      Fear::Right.new(value)
    end
  end
end
