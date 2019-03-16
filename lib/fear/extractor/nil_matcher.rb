module Fear
  module Extractor
    # Match only nil value
    class NilMatcher < Matcher
      def defined_at?(other)
        nil === other
      end
    end
  end
end
