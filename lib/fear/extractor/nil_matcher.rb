module Fear
  module Extractor
    # Match only nil value
    class NilMatcher < Matcher
      def defined_at?(other)
        nil === other
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
