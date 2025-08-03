# frozen_string_literal: true

module Fear
  module PartialFunction
    # Composite function produced by +PartialFunction#and_then+ method
    # @api private
    class AndThen
      include PartialFunction

      # @param partial_function [Fear::PartialFunction]
      # @param function [Proc]
      def initialize(partial_function, &function)
        @partial_function = partial_function
        @function = function
      end
      # @!attribute partial_function
      #   @return [Fear::PartialFunction]
      # @!attribute function
      #   @return [Proc]
      attr_reader :partial_function
      attr_reader :function
      private :partial_function
      private :function

      # @param arg [any]
      # @return [any ]
      def call(arg)
        function.call(partial_function.call(arg))
      end

      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        partial_function.defined_at?(arg)
      end

      # @param arg [any]
      # @yield [arg]
      # @return [any]
      def call_or_else(arg)
        result = partial_function.call_or_else(arg) do
          return yield(arg)
        end
        function.call(result)
      end
    end

    private_constant :AndThen
  end
end
