module Fear
  module Extractor
    class AnonymousArraySplatMatcher < ArraySplatMatcher
      def defined_at?(_other)
        true
      end
    end
  end
end
