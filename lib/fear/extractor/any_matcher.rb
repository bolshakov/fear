module Fear
  module Extractor
    class AnyMatcher < Matcher
      def defined_at?(_other)
        true
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
