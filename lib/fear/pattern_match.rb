# frozen_string_literal: true

module Fear
  # Pattern match builder. Provides DSL for building pattern matcher
  # Pattern match is just a combination of partial functions
  #
  #     matcher = Fear.matcher do |m|
  #       m.case(Integer) { |x| x * 2 }
  #       m.case(String) { |x| x.to_i(10) * 2 }
  #     end
  #     matcher.is_a?(Fear::PartialFunction) #=> true
  #     matcher.defined_at?(4) #=> true
  #     matcher.defined_at?('4') #=> true
  #     matcher.defined_at?(nil) #=> false
  #
  # The previous example is the same as:
  #
  #     Fear.case(Integer) { |x| x * ) }
  #       .or_else(
  #         Fear.case(String) { |x| x.to_i(10) * 2 }
  #       )
  #
  # You can provide +else+ branch, so partial function will be defined
  # on any input:
  #
  #     matcher = Fear.matcher do |m|
  #       m.else { 'Match' }
  #     end
  #     matcher.call(42) #=> 'Match'
  #
  # @see Fear.matcher public interface for building matchers
  # @api Fear
  # @note Use this class only to build custom pattern match classes. See +Fear::OptionPatternMatch+ as an example.
  class PatternMatch
    class << self
      alias __new__ new

      # @return [Fear::PartialFunction]
      def new
        builder = __new__(PartialFunction::EMPTY)
        yield builder
        builder.result
      end

      # Creates anonymous module to add `#mathing` behaviour to a class
      #
      # @example
      #   class User
      #     include Fear::PatternMatch.mixin
      #   end
      #
      #   user.match do |m\
      #     m.case(:admin?) { |u| ... }
      #     m.else { |u| ... }
      #   end
      #
      # @param as [Symbol, String] (:match) method name
      # @return [Module]
      def mixin(as: :match)
        matcher_class = self

        Module.new do
          define_method(as) do |&matchers|
            matcher_class.new(&matchers).(self)
          end
        end
      end
    end

    # @param result [Fear::EmptyPartialFunction]
    def initialize(result)
      @result = result
    end
    attr_accessor :result
    private :result=

    # @see Fear::PartialFunction#else
    def else(&effect)
      or_else(Fear.case(&effect))
    end

    # This method is syntactic sugar for `PartialFunction#or_else`, but rather than passing
    # another partial function as an argument, you pass arguments to build such partial function.
    # @example This two examples produces the same result
    #   other = Fear.case(Integer) { |x| x * 2 }
    #   this.or_else(other)
    #
    #   this.case(Integer) { |x| x * 2 }
    #
    # @param guards [<#===>]
    # @param effect [Proc]
    # @return [Fear::PatternMatch]
    # @see #or_else for details
    def case(*guards, &effect)
      or_else(Fear.case(*guards, &effect))
    end

    # @return [Fear::PatternMatch]
    # @see Fear::PartialFunction#or_else
    def or_else(other)
      self.result = result.or_else(other)
      self
    end
  end
end
