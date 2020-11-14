# frozen_string_literal: true

module Fear
  # Try pattern matcher
  #
  # @note it has two optimized subclasses +Fear::SuccessPatternMatch+ and +Fear::FailurePatternMatch+
  # @api private
  class TryPatternMatch < Fear::PatternMatch
    SUCCESS_EXTRACTOR = :get.to_proc
    private_constant :SUCCESS_EXTRACTOR

    FAILURE_EXTRACTOR = :exception.to_proc
    private_constant :FAILURE_EXTRACTOR

    # Match against +Fear::Success+
    #
    # @param conditions [<#==>]
    # @return [Fear::TryPatternMatch]
    def success(*conditions, &effect)
      branch = Fear.case(Fear::Success, &SUCCESS_EXTRACTOR).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end

    # Match against +Fear::Failure+
    #
    # @param conditions [<#==>]
    # @return [Fear::TryPatternMatch]
    def failure(*conditions, &effect)
      branch = Fear.case(Fear::Failure, &FAILURE_EXTRACTOR).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end
  end
end
