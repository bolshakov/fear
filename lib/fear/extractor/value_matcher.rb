module Fear
  module Extractor
    # Match against values -- true, false, 1, "foo" etc.
    class ValueMatcher < Matcher
      # @!attribute value
      #   @return [Any]

      def defined_at?(arg)
        value === arg
      end

      def bindings(_)
        EMPTY_HASH
      end
    end
  end
end
