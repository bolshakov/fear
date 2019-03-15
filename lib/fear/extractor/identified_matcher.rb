module Fear
  module Extractor
    # Match against and capture variable. E.g. +[foo : Integer]+
    # will check if the first element of an array is Integer and capture it ass +:foo+
    class IdentifiedMatcher < Matcher
      attribute :identifier, IdentifierMatcher
      attribute :matcher, Matcher

      def defined_at?(other)
        matcher.defined_at?(other)
      end

      def bindings(other)
        { identifier.name => other }.merge(matcher.bindings(other))
      end
    end
  end
end
