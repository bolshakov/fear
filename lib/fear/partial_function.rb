module Fear
  # A partial function is a unary function defined on subset of all possible inputs.
  # The method +defined_at?+ allows to test dynamically if a arg is in
  # the domain of the function.
  #
  #  Even if +defined_at?+ returns true for given arg, calling +call+ may
  #  still throw an exception, so the following code is legal:
  #
  #  @example
  #    PartialFunction(->(_) { true }) { 1/0 }
  #
  # It is the responsibility of the caller to call +defined_at?+ before
  # calling +call+, because if +defined_at?+ is false, it is not guaranteed
  # +call+ will throw an exception to indicate an error guard. If an
  # exception is not thrown, evaluation may result in an arbitrary arg.
  #
  # The main distinction between +PartialFunction+ and +Proc+ is
  # that the user of a +PartialFunction+ may choose to do something different
  # with input that is declared to be outside its domain. For example:
  #
  # @example
  #   sample = 1...10
  #
  #   is-even = PartialFunction(->(arg) { arg % 2 == 0}) do |arg|
  #     "#{arg} is even"
  #   end
  #
  #   is_odd = PartialFunction(->(arg) { arg % 2 == 1}) do
  #     "#{arg} is odd"
  #   end
  #
  #   # The method or_else allows chaining another partial function to handle
  #   # input outside the declared domain
  #   numbers = sample.map(is_even.or_else(is_odd).to_proc)
  #
  # @see https://github.com/scala/scala/commit/5050915eb620af3aa43d6ddaae6bbb83ad74900d
  module PartialFunction
    autoload :OrElse, 'fear/partial_function/or_else'
    autoload :AndThen, 'fear/partial_function/and_then'
    autoload :Combined, 'fear/partial_function/combined'
    autoload :EMPTY, 'fear/partial_function/empty'
    autoload :Guard, 'fear/partial_function/guard'
    autoload :GuardAnd, 'fear/partial_function/guard_and'
    autoload :GuardOr, 'fear/partial_function/guard_or'

    # @param condition [#call] describes the domain of partial function
    # @param function [Proc] function definition
    def initialize(condition, &function)
      @condition = condition
      @function = function
    end
    attr_reader :condition, :function
    private :condition
    private :function

    # Checks if a value is contained in the function's domain.
    #
    # @param arg [any]
    # @return [Boolean]
    def defined_at?(arg)
      condition === arg
    end

    # @!method call(arg)
    # @param arg [any]
    # @return [any] Calls this partial function with the given argument when it
    #   is contained in the function domain.
    # @raise [MatchError] when this partial function is not defined.
    # @abstract

    # Converts this partial function to other
    #
    # @return [Proc]
    def to_proc
      proc { |arg| call(arg) }
    end

    # Calls this partial function with the given argument when it is contained in the function domain.
    # Calls fallback function where this partial function is not defined.
    #
    # @param arg [any]
    # @yield [arg] if partial function not defined for this +arg+
    #
    # @note that expression +pf.call_or_else(arg, &fallback)+ is equivalent to
    #   +pf.defined_at?(arg) ? pf.(arg) : fallback.(arg)+
    #   except that +call_or_else+ method can be implemented more efficiently to avoid calling +defined_at?+ twice.
    #
    def call_or_else(arg)
      if defined_at?(arg)
        call(arg)
      else
        yield arg
      end
    end

    # Composes this partial function with a fallback partial function which
    # gets applied where this partial function is not defined.
    #
    # @param other [PartialFunction]
    # @return [PartialFunction] a partial function which has as domain the union of the domains
    #   of this partial function and +other+.
    def or_else(other)
      OrElse.new(self, other)
    end

    # @see or_else
    def |(other)
      or_else(other)
    end

    # @overload and_then(other)
    #   @param other [Fear::PartialFunction]
    #   @return [Fear::PartialFunction] a partial function with the same domain as this partial function, which maps
    #     argument +x+ to +other.(self.call(x))+.
    #   @note calling +#defined_at?+ on the resulting partial function may call the first
    #     partial function and execute its side effect. It is highly recommended to call +#call_or_else+
    #     instead of +#defined_at?+/+#call+ for efficiency.
    # @overload and_then(other)
    #   @param other [Proc]
    #   @return [Fear::PartialFunction] a partial function with the same domain as this partial function, which maps
    #     argument +x+ to +other.(self.call(x))+.
    # @overload and_then(&other)
    #   @param other [Proc]
    #   @return [Fear::PartialFunction]
    #
    def and_then(other = Utils::UNDEFINED, &block)
      Utils.with_block_or_argument('Fear::PartialFunction#and_then', other, block) do |fun|
        if fun.is_a?(Fear::PartialFunction)
          Combined.new(self, fun)
        else
          AndThen.new(self, &fun)
        end
      end
    end

    # @see and_then
    def &(other)
      and_then(other)
    end

    class << self
      # Creates partial function guarded by several condition.
      # All conditions should match.
      # @param guards [<#===, symbol>]
      # @param function [Proc]
      # @return [Fear::PartialFunction]
      def and(*guards, &function)
        PartialFunctionClass.new(Guard.and(guards), &function)
      end

      # Creates partial function guarded by several condition.
      # Any condition should match.
      # @param guards [<#===, symbol>]
      # @param function [Proc]
      # @return [Fear::PartialFunction]
      def or(*guards, &function)
        PartialFunctionClass.new(Guard.or(guards), &function)
      end
    end

    module Mixin
      PartialFunction = Fear::PartialFunction

      # Creates partial function defined on domain described with guards
      # @example
      #   pf = PartialFunction(Integer) { |x| x / 2 }
      #   pf.defined_at?(4) #=> true
      #   pf.defined_at?('Foo') #=> false
      #
      # @example multiple guards combined using logical and
      #   pf = PartialFunction(Integer, :even?) { |x| x / 2 }
      #   pf.defined_at?(4) #=> true
      #   pf.defined_at?(3) #=> false
      #
      # @note to make more complex matches, you are encouraged to
      #   use Qo gem.
      # @see Qo https://github.com/baweaver/qo
      # @example
      #   PartialFunction(Qo[age: 20..30]) { |_| 'old enough' }
      #
      # @param guards [<#===, symbol>]
      # @param function [Proc]
      # @return [Fear::PartialFunction]
      def PartialFunction(*guards, &function)
        PartialFunction.and(*guards, &function)
      end
    end
  end
end
