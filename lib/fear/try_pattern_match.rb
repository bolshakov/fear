# frozen_string_literal: true

require "fear/pattern_match"

module Fear
  # Try pattern matcher
  #
  # @note it has two optimized subclasses +Fear::SuccessPatternMatch+ and +Fear::FailurePatternMatch+
  # @api private
  class TryPatternMatch < Fear::PatternMatch
    # Match against +Fear::Success+
    #
    # @param conditions [<#==>]
    # @return [Fear::TryPatternMatch]
    def success(*conditions, &effect)
      branch = Fear.case(Fear::Success, &:get).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end

    # Match against +Fear::Failure+
    #
    # @param conditions [<#==>]
    # @return [Fear::TryPatternMatch]
    def failure(*conditions, &effect)
      branch = Fear.case(Fear::Failure, &:exception).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end
  end
end

require "fear/success_pattern_match"
require "fear/failure_pattern_match"
