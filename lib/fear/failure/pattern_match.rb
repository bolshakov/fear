# frozen_string_literal: true

module Fear
  class Failure
    # @api private
    class PatternMatch < Try::PatternMatch
      def success(*_conditions)
        self
      end
    end

    private_constant :PatternMatch
  end
end
