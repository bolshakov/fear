module Fear
  module Extractor
    # Recursive array matcher. Match against its head and tail
    #
    class ArrayMatcher < Matcher
      # @!attribute head
      #   @return [ArrayHeadMatcher | ArraySplatMatcher]
      # @!attribute tail
      #   @return [ArrayMatcher | EmptyListMatcher]
      # @!attribute index
      #   @return [Types::Strict::Integer]

      def defined_at?(other)
        if other.is_a?(Array)
          if head.is_a?(ArraySplatMatcher)
            true
          else
            unless other.empty?
              other_head, *other_tail = other
              head.defined_at?(other_head) && tail.defined_at?(other_tail)
            end
          end
        end
      end

      def bindings(other)
        if head.is_a?(ArraySplatMatcher)
          head.bindings(other)
        else
          other_head, *other_tail = other
          head.bindings(other_head).merge(tail.bindings(other_tail))
        end
      end

      def failure_reason(other)
        if head.is_a?(ArraySplatMatcher)
          super
        else
          other_head, *other_tail = other
          if head.defined_at?(other_head)
            tail.failure_reason(other_tail)
          else
            head.failure_reason(other_head)
          end
        end
      end
    end
  end
end
