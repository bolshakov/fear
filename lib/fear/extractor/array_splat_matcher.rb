module Fear
  module Extractor
    # @abstract
    class ArraySplatMatcher < Matcher
      def defined_at?(_other)
        true
      end

      def bindings(_)
        EMPTY_HASH
      end
    end
  end
end
