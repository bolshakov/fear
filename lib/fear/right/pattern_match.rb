# frozen_string_literal: true

module Fear
  class Right
    # @api private
    class PatternMatch < Either::PatternMatch
      def left(*)
        self
      end
      alias_method :failure, :left
    end

    private_constant :PatternMatch
  end
end
