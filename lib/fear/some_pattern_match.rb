module Fear
  # @api private
  class SomePatternMatch < OptionPatternMatch
    # @return [Fear::OptionPatternMatch]
    def none
      self
    end
  end

  private_constant :SomePatternMatch
end
