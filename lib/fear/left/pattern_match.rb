# frozen_string_literal: true

module Fear
  class Left
    # @api private
    class PatternMatch < Fear::Either::PatternMatch
      def right(*)
        self
      end
      alias_method :success, :right
    end

    private_constant :PatternMatch
  end
end
