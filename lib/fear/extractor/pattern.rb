module Fear
  module Extractor
    class Pattern
      def initialize(pattern)
        parser = Extractor::GrammarParser.new
        if (result = parser.parse(pattern))
          @matcher = result.to_matcher
        else
          raise PatternSyntaxError, syntax_error_message(parser, pattern)
        end
      end
      attr_reader :matcher
      private :matcher

      def ===(other)
        matcher.defined_at?(other)
      end

      def extracted_arguments(other)
        matcher.call(other).get_or_else do
          raise ArgumentError, 'extracting arguments of not matcher pattern'
        end
      end

      private def syntax_error_message(parser, pattern)
        parser.failure_reason =~ /^(Expected .+) after/m
        "#{Regexp.last_match(1).gsub("\n", '$NEWLINE')}:\n" +
        pattern.split("\n")[parser.failure_line - 1] + "\n" \
        "#{'~' * (parser.failure_column - 1)}^\n"
      end
    end
  end
end
