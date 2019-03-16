module Fear
  module Extractor
    # Match against boolean values -- true and false
    class BooleanMatcher < Matcher
      # @!attribute value
      #   @return [Types::Strict::Bool]

      def defined_at?(other)
        value === other
      end

      def bindings(_)
        EMPTY_HASH
      end
    end
  end
end
