module Fear
  module Extractor
    # Match against Integer or float. E.g. +42+ or +42.2+
    class NumberMatcher < Matcher
      # @!attribute value
      #   @return [Types::Strict::Integer | Types::Strict::Float]
      # @!attribute node
      #   @return [Types.Instance(Grammar::IntegerLiteral) | Types.Instance(Grammar::FloatLiteral)]

      def defined_at?(other)
        value === other
      end
    end
  end
end
