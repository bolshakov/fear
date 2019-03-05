module Fear
  module PartialFunction
    # @api private
    class OrElse
      include PartialFunction

      # @param f1 [Fear::PartialFunction]
      # @param f2 [Fear::PartialFunction]
      def initialize(f1, f2)
        @f1 = f1
        @f2 = f2
      end

      # @param arg [any]
      # @return [any]
      def call(arg)
        @f1.call_or_else(arg, &@f2)
      end

      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        @f1.defined_at?(arg) || @f2.defined_at?(arg)
      end

      # @param arg [any]
      # @param fallback [Proc]
      # @return [any]
      def call_or_else(arg, &fallback)
        if @f1.defined_at?(arg)
          @f1.call(arg)
        elsif @f2.defined_at?(arg)
          @f2.call(arg)
        else
          yield arg
        end
      end
    end

    private_constant :OrElse
  end
end
