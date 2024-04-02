# frozen_string_literal: true

require "fear/either/pattern_match"

module Fear
  class Right
    # @api private
    class PatternMatch < Either::PatternMatch
      def left(*)
        self
      end
      alias failure left
    end

    private_constant :PatternMatch
  end
end
