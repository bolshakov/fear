module Fear
  module Extractor
    class ArrayHeadMatcher < Matcher
      attribute :element, IntegerMatcher
      attribute :index, Types::Strict::Integer

      def defined_at?(other)
        element.defined_at?(other)
      end

      def bindings(other)
        element.bindings(other)
      end
    end
  end
end
