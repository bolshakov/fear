module Fear
  module PartialFunction
    # @api private
    class Combined
      include PartialFunction

      # @param f1 [Fear::PartialFunction]
      # @param f2 [Fear::PartialFunction]
      def initialize(f1, f2)
        @f1 = f1
        @f2 = f2
      end

      # @param arg [any]
      # @return [any ]
      def call(arg)
        @f2.call(@f1.call(arg))
      end

      # FIXME: optimize calling defined_at on @f1 twise
      # @param arg [any]
      # @return [Boolean]
      def defined_at?(arg)
        if @f1.defined_at?(arg)
          @f2.defined_at?(@f1.call(arg))
        else
          false
        end
      end

      # FIXME: optimize calling defined_at on @f1 twise
      # @param arg [any]
      # @param fallback [Proc]
      # @return [any]
      def call_or_else(arg)
        if @f1.defined_at?(arg)
          @f2.call_or_else(@f1.call(arg)) do |_|
            yield arg
          end
        else
          yield arg
        end
      end
    end

    private_constant :AndThen
  end
end
