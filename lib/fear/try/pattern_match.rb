# frozen_string_literal: true

require "fear/pattern_match"

module Fear
  module Try
    # Try pattern matcher
    #
    # @note it has two optimized subclasses +Fear::Success::PatternMatch+ and +Fear::FailurePatternMatch+
    # @api private
    class PatternMatch < Fear::PatternMatch
      # Match against +Fear::Success+
      #
      # @param conditions [<#==>]
      # @return [Fear::Try::PatternMatch]
      def success(*conditions, &effect)
        branch = Fear.case(Fear::Success, &:get).and_then(Fear.case(*conditions, &effect))
        or_else(branch)
      end

      # Match against +Fear::Failure+
      #
      # @param conditions [<#==>]
      # @return [Fear::Try::PatternMatch]
      def failure(*conditions, &effect)
        branch = Fear.case(Fear::Failure, &:exception).and_then(Fear.case(*conditions, &effect))
        or_else(branch)
      end
    end
  end
end
