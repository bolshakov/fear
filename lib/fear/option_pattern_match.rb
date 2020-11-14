# frozen_string_literal: true

module Fear
  # Option pattern matcher
  #
  # @example
  #   pattern_match =
  #     OptionPatternMatch.new
  #       .some(Integer) { |x| x * 2 }
  #       .some(String) { |x| x.to_i * 2 }
  #       .none { 'NaN' }
  #       .else { 'error '}
  #
  #   pattern_match.call(42) => 'NaN'
  #
  #  @example the same matcher may be defined using block syntax
  #    OptionPatternMatch.new do |m|
  #       m.some(Integer) { |x| x * 2 }
  #       m.some(String) { |x| x.to_i * 2 }
  #       m.none { 'NaN' }
  #       m.else { 'error '}
  #    end
  #
  # @note it has two optimized subclasses +Fear::SomePatternMatch+ and +Fear::NonePatternMatch+
  # @api private
  class OptionPatternMatch < Fear::PatternMatch
    GET_METHOD = :get.to_proc
    private_constant :GET_METHOD

    # Match against Some
    #
    # @param conditions [<#==>]
    # @return [Fear::OptionPatternMatch]
    def some(*conditions, &effect)
      branch = Fear.case(Fear::Some, &GET_METHOD).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end

    # Match against None
    #
    # @param effect [Proc]
    # @return [Fear::OptionPatternMatch]
    def none(&effect)
      branch = Fear.case(Fear::None, &effect)
      or_else(branch)
    end
  end
end
