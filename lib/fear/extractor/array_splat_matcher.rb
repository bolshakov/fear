module Fear
  module Extractor
    # @abstract
    class ArraySplatMatcher < Matcher
      def defined_at?(_other)
        true
      end
    end
  end
end
