# frozen_string_literal: true

module Fear
  # @api private
  class RightPatternMatch < EitherPatternMatch
    def left(*)
      self
    end
    alias failure left
  end
end
