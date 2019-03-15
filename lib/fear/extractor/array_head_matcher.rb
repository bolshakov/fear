module Fear
  module Extractor
    # Part of recursive array matcher. Match against its head.
    # @see ArrayMatcher
    class ArrayHeadMatcher < Matcher
      attribute :element, Matcher
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
