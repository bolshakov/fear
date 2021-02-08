# frozen_string_literal: true

require "fear/either_pattern_match"

module Fear
  # @api private
  class RightPatternMatch < EitherPatternMatch
    def left(*)
      self
    end
    alias failure left
  end
end
