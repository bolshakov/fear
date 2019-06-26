# typed: false
module Fear
  module Extractor
    # Part of recursive array matcher. Match against its head.
    # @see ArrayMatcher
    class ArrayHeadMatcher < Matcher
      # @!attribute matcher
      #   @return [Matcher]
      # @!attribute index
      #   @return [Types::Strict::Integer]

      # @param other [<>]
      def defined_at?(other)
        if other.empty?
          false
        else
          matcher.defined_at?(other.first)
        end
      end

      # @param other [<>]
      def bindings(other)
        if other.empty?
          super
        else
          matcher.bindings(other.first)
        end
      end

      def failure_reason(other)
        matcher.failure_reason(other.first)
      end
    end
  end
end
