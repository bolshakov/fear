module Fear
  module Extractor
    class ArraySplatMatcher < Matcher
      def defined_at?(_other)
        true
      end
    end
  end
end
