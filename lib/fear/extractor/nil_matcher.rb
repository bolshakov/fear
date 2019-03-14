module Fear
  module Extractor
    class NilMatcher < Matcher
      attribute :value, Types::Strict::Nil

      def defined_at?(other)
        value === other
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
