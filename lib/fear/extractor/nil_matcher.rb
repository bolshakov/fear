module Fear
  module Extractor
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