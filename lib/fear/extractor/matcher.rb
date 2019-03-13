module Fear
  module Extractor
    class Matcher < Dry::Struct
      attribute :node, Types.Instance(Fear::Extractor::Grammar::Node)

      def defined_at?(_)
        raise NoMethodError
      end

      def call(other)
        if defined_at?(other)
          Fear.some(bindings(other))
        else
          Fear.none
        end
      end

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
