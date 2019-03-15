module Fear
  module Extractor
    # @abstract abstract matcher to inherit from.
    class Matcher < Dry::Struct
      attribute :node, Types.Instance(Fear::Extractor::Grammar::Node)

      # Checks if matcher match against provided argument
      # @param _argument [any]
      # @return [Boolean]
      def defined_at?(_argument)
        raise NoMethodError
      end

      def call(other)
        if defined_at?(other)
          Fear.some(bindings(other))
        else
          Fear.none
        end
      end

      # Extracts binding from matcher
      # @param _argument [any]
      # @return [Hash<Symbol => any>]
      def bindings(_argument)
        raise NoMethodError
      end

      # Shows why matcher has failed. Use it for debugging.
      # @example
      #   Fear['[1, 2, _]'].failure_reason([1, 3, 4])
      #   # it will show that the second element hasn't match
      #
      def failure_reason(other)
        if defined_at?(other)
          Fear.none
        else
          Fear.some("Expected #{other} to match #{node.input} here:\n#{node.show_position}")
        end
      end
    end
  end
end
