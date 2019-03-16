module Fear
  module Extractor
    # Match against values -- true, false, 1, "foo" etc.
    class ValueMatcher < Matcher
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