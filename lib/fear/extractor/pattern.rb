# frozen_string_literal: true

require "lru_redux"

module Fear
  module Extractor
    # Parse pattern. Used within +Fear[]+
    class Pattern
      DEFAULT_PATTERN_CACHE_SIZE = 10_000
      @pattern_cache = LruRedux::Cache.new(ENV.fetch("FEAR_PATTERNS_CACHE_SIZE", DEFAULT_PATTERN_CACHE_SIZE))

      class << self
        attr_reader :pattern_cache
      end

      def initialize(pattern)
        @matcher = compile_pattern(pattern)
      end
      attr_reader :matcher
      private :matcher

      private def compile_pattern(pattern)
        self.class.pattern_cache.getset(pattern) do
          compile_pattern_without_cache(pattern)
        end
      end

      private def compile_pattern_without_cache(pattern)
        parser = Extractor::GrammarParser.new
        if (result = parser.parse(pattern))
          result.to_matcher
        else
          raise PatternSyntaxError, syntax_error_message(parser, pattern)
        end
      end

      def ===(other)
        matcher.defined_at?(other)
      end

      def and_then(other)
        Fear::PartialFunction::Combined.new(matcher, other)
      end

      def failure_reason(other)
        matcher.failure_reason(other).get_or_else { "It matches" }
      end

      private def syntax_error_message(parser, pattern)
        parser.failure_reason =~ /^(Expected .+) after/m
        "#{Regexp.last_match(1).gsub("\n", "$NEWLINE")}:\n" +
        pattern.split("\n")[parser.failure_line - 1] + "\n" \
        "#{"~" * (parser.failure_column - 1)}^\n"
      end
    end
  end
end
