# frozen_string_literal: true

module Fear
  module Either
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
    # @note it has two optimized subclasses +Fear::Left::PatternMatch+ and +Fear::Right::PatternMatch+
    # @api private
    class PatternMatch < Fear::PatternMatch
      # Match against +Fear::Right+
      #
      # @param conditions [<#==>]
      # @return [Fear::Either::PatternMatch]
      def right(*conditions, &effect)
        branch = Fear.case(Fear::Right, &:right_value).and_then(Fear.case(*conditions, &effect))
        or_else(branch)
      end
      alias_method :success, :right

      # Match against +Fear::Left+
      #
      # @param conditions [<#==>]
      # @return [Fear::Either::PatternMatch]
      def left(*conditions, &effect)
        branch = Fear.case(Fear::Left, &:left_value).and_then(Fear.case(*conditions, &effect))
        or_else(branch)
      end
      alias_method :failure, :left
    end
  end
end
