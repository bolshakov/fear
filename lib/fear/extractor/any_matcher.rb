# frozen_string_literal: true

module Fear
  module Extractor
    # Always match, E.g. `_ : Integer` without capturing variable
    #
    class AnyMatcher < Matcher
      def defined_at?(_other)
        true
      end

      def bindings(_)
        EMPTY_HASH
      end
    end
  end
end
