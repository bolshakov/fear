require 'qo'

module Fear
  # Should be prepended to Qo::PatternMatchers::PatternMatch
  # @see Qo::PatternMatchers::PatternMatch
  module ExhaustivePatternMatch
    EXHAUSTIVE_PATTERN_MATCH_ERROR = <<-ERROR.freeze
      Pattern match is not exhaustive.

      You've got this error because pattern match is not exhaustive. The
      simplest way to resolve this error is to add `else` branch. For example:

      monad.match do |m|
        # ...
        m.else { 'not matched' }
      end
    ERROR

    def initialize(*)
      super
      @default ||= self.else { raise MatchError, EXHAUSTIVE_PATTERN_MATCH_ERROR }
    end
  end

  private_constant :ExhaustivePatternMatch
end
