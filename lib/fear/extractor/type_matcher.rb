module Fear
  module Extractor
    # Match against type, e.g. +Integer+
    class TypeMatcher < Matcher
      # attribute :class_name, Types::Strict::String

      def defined_at?(other)
        Object.const_get(class_name) === other
      end
    end
  end
end
