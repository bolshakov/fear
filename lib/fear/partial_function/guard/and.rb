module Fear
  module PartialFunction
    class Guard
      # @api private
      class And < Guard
        # @param c1 [Fear::PartialFunction::Guard]
        # @param c2 [Fear::PartialFunction::Guard]
        def initialize(c1, c2)
          @c1 = c1
          @c2 = c2
        end
        attr_reader :c1, :c2
        private :c1
        private :c2

        # @param other [Fear::PartialFunction::Guard]
        # @return [Fear::PartialFunction::Guard]
        def and(other)
          Guard::And.new(self, other)
        end

        # @param other [Fear::PartialFunction::Guard]
        # @return [Fear::PartialFunction::Guard]
        def or(other)
          Guard::Or.new(self, other)
        end

        # @param arg [any]
        # @return [Boolean]
        def ===(arg)
          (c1 === arg) && (c2 === arg)
        end
      end
    end
  end
end
