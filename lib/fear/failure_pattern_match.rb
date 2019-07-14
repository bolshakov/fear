# frozen_string_literal: true

module Fear
  # @api private
  class FailurePatternMatch < Fear::TryPatternMatch
    def success(*_conditions)
      self
    end
  end
end
