module Fear
  module Extractor
    class AnonymousArraySplatMatcher < ArraySplatMatcher
      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
