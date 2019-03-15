module Fear
  module Extractor
    # @see IdentifiedMatcher
    class IdentifierMatcher < Matcher
      attribute :name, Types::Strict::Symbol

      def defined_at?(_)
        true
      end

      def bindings(other)
        { name => other }
      end
    end
  end
end
