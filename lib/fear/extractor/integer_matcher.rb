module Fear
  module Extractor
    class IntegerMatcher < Matcher
      attribute :value, Types::Strict::Integer
      attribute :node, Types.Instance(Grammar::IntegerLiteral)

      def defined_at?(other)
        value === other
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
