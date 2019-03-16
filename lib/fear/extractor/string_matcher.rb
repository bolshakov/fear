module Fear
  module Extractor
    # Match against string. E.g. +"Foo"+ or +'bar'+
    #
    class StringMatcher < Matcher
      # @!attribute value
      #   @return [Types::Strict::String]
      # @!attribute node
      #   @return [Types.Instance(Grammar::StringLiteral)]

      def defined_at?(other)
        value === other
      end
    end
  end
end
