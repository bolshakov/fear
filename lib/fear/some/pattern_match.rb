# frozen_string_literal: true

module Fear
  class Some
    # @api private
    class PatternMatch < Option::PatternMatch
      # @return [Fear::OptionPatternMatch]
      def none
        self
      end
    end

    private_constant :PatternMatch
  end
end
