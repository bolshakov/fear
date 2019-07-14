# frozen_string_literal: true

module Fear
  module PartialFunction
    # Composite function produced by +PartialFunction#or_else+ method
    # @api private
    class OrElse
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
      # @return [any]
      def call(arg)
        f1.call_or_else(arg, &f2)
      end

      alias === call
      alias [] call

      # @param other [Fear::PartialFunction]
      # @return [Fear::PartialFunction]
      def or_else(other)
        OrElse.new(f1, f2.or_else(other))
      end

      # @see Fear::PartialFunction#and_then
      def and_then(other = Utils::UNDEFINED, &block)
        Utils.with_block_or_argument("Fear::PartialFunction::OrElse#and_then", other, block) do |fun|
          OrElse.new(f1.and_then(&fun), f2.and_then(&fun))
        end
      end

      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        f1.defined_at?(arg) || f2.defined_at?(arg)
      end

      # @param arg [any]
      # @param fallback [Proc]
      # @return [any]
      def call_or_else(arg, &fallback)
        f1.call_or_else(arg) do
          return f2.call_or_else(arg, &fallback)
        end
      end
    end

    private_constant :OrElse
  end
end
