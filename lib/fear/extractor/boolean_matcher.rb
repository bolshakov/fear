module Fear
  module Extractor
    class BooleanMatcher < Matcher
      attribute :value, Types::Strict::Bool

      def defined_at?(other)
        value === other
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
