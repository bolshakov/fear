# frozen_string_literal: true

module Fear
  class Success
    # @api private
    class PatternMatch < Try::PatternMatch
      # @param conditions [<#==>]
      # @return [Fear::TryPatternMatch]
      def failure(*conditions)
        self
      end
    end

    private_constant :PatternMatch
  end
end
