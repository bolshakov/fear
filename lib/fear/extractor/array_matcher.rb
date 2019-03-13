module Fear
  module Extractor
    class ArrayMatcher < Matcher
      attribute :elements, Types::Strict::Array.default(Dry::Core::Constants::EMPTY_ARRAY)
      attribute :node, Types.Instance(Grammar::ArrayLiteral)

      def defined_at?(other)
        other.size == elements.size && elements.each_with_index.all? do |element, index|
          element.defined_at?(other[index])
        end
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end

      def failure_reason(other)
        if other.size != elements.size
          Fear.some(super)
        else
          find_element_failure(other)
        end
      end

      private def find_element_failure(other)
        elements.each_with_index.detect(-> { Fear.none }) do |(element, index)|
          unless element.defined_at?(other[index])
            return element.failure_reason(other[index])
          end
        end
      end
    end
  end
end
