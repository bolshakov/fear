module Fear
  module Extractor
    # Match against Integer or float. E.g. +42+ or +42.2+
    class NumberMatcher < Matcher
      attribute :value, Types::Strict::Integer | Types::Strict::Float
      attribute :node, Types.Instance(Grammar::IntegerLiteral) | Types.Instance(Grammar::FloatLiteral)

      def defined_at?(other)
        value === other
      end

      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
