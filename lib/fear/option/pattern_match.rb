# frozen_string_literal: true

module Fear
  module Option
    # Option pattern matcher
    #
    # @example
    #   pattern_match =
    #     Option::PatternMatch.new
    #       .some(Integer) { |x| x * 2 }
    #       .some(String) { |x| x.to_i * 2 }
    #       .none { 'NaN' }
    #       .else { 'error '}
    #
    #   pattern_match.call(42) => 'NaN'
    #
    #  @example the same matcher may be defined using block syntax
    #    Option::PatternMatch.new do |m|
    #       m.some(Integer) { |x| x * 2 }
    #       m.some(String) { |x| x.to_i * 2 }
    #       m.none { 'NaN' }
    #       m.else { 'error '}
    #    end
    #
    # @note it has two optimized subclasses +Fear::SomePatternMatch+ and +Fear::NonePatternMatch+
    # @api private
    class PatternMatch < Fear::PatternMatch
      # Match against Some
      #
      # @param conditions [<#==>]
      # @return [Fear::Option::PatternMatch]
      def some(*conditions, &effect)
        branch = Fear.case(Fear::Some, &:get).and_then(Fear.case(*conditions, &effect))
        or_else(branch)
      end

      # Match against None
      #
      # @param effect [Proc]
      # @return [Fear::Option::PatternMatch]
      def none(&effect)
        branch = Fear.case(Fear::None, &effect)
        or_else(branch)
      end
    end
  end
end
