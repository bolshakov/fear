# frozen_string_literal: true

module Fear
  # Either pattern matcher
  #
  # @example
  #   pattern_match =
  #     EitherPatternMatch.new
  #       .right(Integer, ->(x) { x > 2 }) { |x| x * 2 }
  #       .right(String) { |x| x.to_i * 2 }
  #       .left(String) { :err }
  #       .else { 'error '}
  #
  #   pattern_match.call(42) => 'NaN'
  #
  #  @example the same matcher may be defined using block syntax
  #    EitherPatternMatch.new do |m|
  #      m.right(Integer, ->(x) { x > 2 }) { |x| x * 2 }
  #      m.right(String) { |x| x.to_i * 2 }
  #      m.left(String) { :err }
  #      m.else { 'error '}
  #    end
  #
  # @note it has two optimized subclasses +Fear::LeftPatternMatch+ and +Fear::RightPatternMatch+
  # @api private
  class EitherPatternMatch < Fear::PatternMatch
    LEFT_EXTRACTOR = :left_value.to_proc
    public_constant :LEFT_EXTRACTOR

    RIGHT_EXTRACTOR = :right_value.to_proc
    public_constant :RIGHT_EXTRACTOR

    # Match against +Fear::Right+
    #
    # @param conditions [<#==>]
    # @return [Fear::EitherPatternMatch]
    def right(*conditions, &effect)
      branch = Fear.case(Fear::Right, &RIGHT_EXTRACTOR).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end
    alias success right

    # Match against +Fear::Left+
    #
    # @param conditions [<#==>]
    # @return [Fear::EitherPatternMatch]
    def left(*conditions, &effect)
      branch = Fear.case(Fear::Left, &LEFT_EXTRACTOR).and_then(Fear.case(*conditions, &effect))
      or_else(branch)
    end
    alias failure left
  end
end
