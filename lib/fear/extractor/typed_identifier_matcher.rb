module Fear
  module Extractor
    # Match and capture identifier with specific type. E.g. +foo : Integer+
    #
    class TypedIdentifierMatcher < Matcher
      # @!attribute identifier
      #   @return [IdentifierMatcher]
      # @!attribute type
      #   @return [TypeMatcher]

      def defined_at?(other)
        type.defined_at?(other)
      end

      def bindings(other)
        { identifier.name => other }
      end

      def failure_reason(other)
        type.failure_reason(other)
      end
    end
  end
end
