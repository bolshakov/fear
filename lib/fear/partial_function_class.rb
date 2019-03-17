module Fear
  # @api private
  class PartialFunctionClass
    include PartialFunction

    # @param condition [#call] describes the domain of partial function
    # @param function [Proc] function definition
    def initialize(condition, &function)
      @condition = condition
      @function = function
    end
    attr_reader :condition, :function
    private :condition
    private :function

    # @param arg [any]
    # @return [any] Calls this partial function with the given argument when it
    #   is contained in the function domain.
    # @raise [MatchError] when this partial function is not defined.
    def call(arg)
      call_or_else(arg, &PartialFunction::EMPTY)
    end

    # @param arg [any]
    # @yield [arg] if function not defined
    def call_or_else(arg)
      if defined_at?(arg)
        function.call(arg)
      else
        yield arg
      end
    end
  end

  private_constant :PartialFunctionClass
end
