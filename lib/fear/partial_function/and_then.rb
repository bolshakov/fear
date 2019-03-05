module Fear
  module PartialFunction
    # @api private
    class AndThen
      include PartialFunction

      # @param partial_function [Fear::PartialFunction]
      # @param function [Proc]
      def initialize(partial_function, &function)
        @partial_function = partial_function
        @function = function
      end

      # @param arg [any]
      # @return [any ]
      def call(arg)
        @function.call(@partial_function.call(arg))
      end

      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        @partial_function.defined_at?(arg)
      end

      # @param arg [any]
      # @param fallback [Proc]
      # @return [any]
      def call_or_else(arg, &fallback)
        if @partial_function.defined_at?(arg)
          @function.call(@partial_function.call(arg))
        else
          yield arg
        end
      end
    end

    private_constant :AndThen
  end
end
