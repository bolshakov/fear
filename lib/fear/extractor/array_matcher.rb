module Fear
  module Extractor
    # Recursive array matcher. Match against its head and tail
    #
    class ArrayMatcher < Matcher
      # @!attribute head
      #   @return [ArrayHeadMatcher]
      # @!attribute tail
      #   @return [ArrayMatcher | EmptyListMatcher]

      def defined_at?(other)
        if other.is_a?(Array)
          head.defined_at?(other) && tail.defined_at?(other.slice(1..-1))
        end
      end

      def bindings(other)
        if head.is_a?(ArraySplatMatcher)
          head.bindings(other)
        else
          head.bindings(other).merge(tail.bindings(other.slice(1..-1)))
        end
      end

      def failure_reason(other)
        if other.is_a?(Array)
          if head.defined_at?(other)
            tail.failure_reason(other.slice(1..-1))
          else
            head.failure_reason(other)
          end
        else
          super
        end
      end
    end
  end
end
