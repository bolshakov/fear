module Fear
  module PartialFunction
    # @api private
    class GuardOr < Guard
      # @param c1 [Fear::PartialFunction::Guard]
      # @param c2 [Fear::PartialFunction::Guard]
      def initialize(c1, c2)
        @c1 = c1
        @c2 = c2
      end

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def and(other)
        GuardAnd.new(self, other)
      end

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def or(other)
        GuardOr.new(self, other)
      end

      # @param arg [any]
      # @return [Boolean]
      def ===(arg)
        (@c1 === arg) || (@c2 === arg)
      end
    end
  end
end
