# typed: false
module Fear
  module Extractor
    # Match and extract pattern using registered extractor objects
    # E.g. +Some(a : Integer)+
    # @see Extractor.register_extractor
    class ExtractorMatcher < Matcher
      # @!attribute name
      #   @return [Types::Strict::String]
      # @!attribute arguments_matcher
      #   @return [ArrayMatcher | EmptyListMatcher]
      #

      def initialize(*)
        super
        @extractor = Extractor.find_extractor(name)
      end
      attr_reader :extractor
      private :extractor

      def defined_at?(other)
        extractor
          .call(other)
          .map { |v| arguments_matcher.defined_at?(v) }
          .get_or_else { false }
      end

      def call_or_else(arg)
        extractor.call(arg)
          .map { |v| arguments_matcher.call_or_else(v) { yield arg } }
          .get_or_else { yield arg }
      end

      def failure_reason(other)
        extractor.call(other).match do |m|
          m.some(->(v) { arguments_matcher.defined_at?(v) }) { Fear.none }
          m.some { |v| arguments_matcher.failure_reason(v) }
          m.none { super }
        end
      end
    end
  end
end
