# typed: false
module Fear
  # @api private
  class NonePatternMatch < OptionPatternMatch
    # @param conditions [<#==>]
    # @return [Fear::OptionPatternMatch]
    def some(*_conditions)
      self
    end
  end

  private_constant :NonePatternMatch
end
