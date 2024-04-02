# frozen_string_literal: true

module Fear
  class NoneClass
    # @api private
    class PatternMatch < Option::PatternMatch
      # @param conditions [<#==>]
      # @return [Fear::OptionPatternMatch]
      def some(*conditions)
        self
      end
    end

    private_constant :PatternMatch
  end
end
