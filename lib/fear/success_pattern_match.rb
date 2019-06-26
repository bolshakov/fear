# typed: true
module Fear
  # @api private
  class SuccessPatternMatch < Fear::TryPatternMatch
    # @param conditions [<#==>]
    # @return [Fear::TryPatternMatch]
    def failure(*_conditions)
      self
    end
  end
end
