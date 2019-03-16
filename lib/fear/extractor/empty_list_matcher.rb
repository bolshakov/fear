module Fear
  module Extractor
    # Match only if array is empty
    #
    class EmptyListMatcher < Matcher
      # @!attribute index
      #   @return [Types::Strict::Integer]
      #
      def defined_at?(other)
        other.empty?
      end
    end
  end
end
