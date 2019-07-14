# frozen_string_literal: true

module Fear
  module PartialFunction
    class Guard
      # @api private
      class And3 < Guard
        # @param c1 [#===]
        # @param c2 [#===]
        # @param c3 [#===]
        def initialize(c1, c2, c3)
          @c1 = c1
          @c2 = c2
          @c3 = c3
        end
        attr_reader :c1, :c2, :c3
        private :c1
        private :c2
        private :c3

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
          (c1 === arg) && (c2 === arg) && (c3 === arg)
        end
      end
    end
  end
end
