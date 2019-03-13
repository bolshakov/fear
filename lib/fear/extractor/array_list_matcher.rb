module Fear
  module Extractor
    class ArrayListMatcher < Matcher
      attribute :head, ArrayHeadMatcher | ArraySplatMatcher
      attribute :tail, ArrayListMatcher | EmptyListMatcher
      attribute :index, Types::Strict::Integer

      def defined_at?(other)
        if other.is_a?(Array)
          if head.is_a?(ArraySplatMatcher)
            true
          else
            other_head, *other_tail = other
            head.defined_at?(other_head) && tail.defined_at?(other_tail)
          end
        end
      end

      def bindings(other)
        if head.is_a?(AnonymousArraySplatMatcher)
          Dry::Core::Constants::EMPTY_HASH
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
