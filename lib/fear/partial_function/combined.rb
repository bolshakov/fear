# frozen_string_literal: true

module Fear
  module PartialFunction
    # Composite function produced by +PartialFunction#and_then+ method
    # @api private
    class Combined
      include PartialFunction

      # @param f1 [Fear::PartialFunction]
      # @param f2 [Fear::PartialFunction]
      def initialize(f1, f2)
        @f1 = f1
        @f2 = f2
      end
      # @!attribute f1
      #   @return [Fear::PartialFunction]
      # @!attribute f2
      #   @return [Fear::PartialFunction]
      attr_reader :f1, :f2
      private :f1
      private :f2

      # @param arg [any]
      # @return [any ]
      def call(arg)
        f2.call(f1.call(arg))
      end

      alias_method :===, :call
      alias_method :[], :call

      # @param arg [any]
      # @yieldparam arg [any]
      # @return [any]
      def call_or_else(arg)
        result = f1.call_or_else(arg) { return yield(arg) }
        f2.call_or_else(result) { |_| return yield(arg) }
      end

      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        result = f1.call_or_else(arg) do
          return false
        end
        f2.defined_at?(result)
      end
    end

    private_constant :AndThen
  end
end
