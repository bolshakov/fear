module Fear
  # @api private
  class LeftPatternMatch < Fear::EitherPatternMatch
    def right(*)
      self
    end
    alias success right
  end
end
