# frozen_string_literal: true

module Fear
  module Extractor
    # @abstract
    class ArraySplatMatcher < Matcher
      def defined_at?(_other)
        true
      end

      def bindings(_)
        Utils::EMPTY_HASH
      end
    end
  end
end
