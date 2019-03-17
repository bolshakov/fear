module Fear
  module Extractor
    # Match and extract pattern using registered extractor objects
    # E.g. +Some(a : Integer)+
    # @see Extractor.register_extractor
    class ExtractorMatcher < Matcher
      # @!attribute name
      #   @return [Types::Strict::String]
      # attribute :arguments_matcher, ArrayMatcher | EmptyListMatcher

      def defined_at?(other)
        Fear::Option.match(extract(other)) do |m|
          m.some { |v| arguments_matcher.defined_at?([v].flatten) }
          m.none { false }
          m.case(true, &:itself)
          m.case(false, &:itself)
          m.else do |v|
            raise TypeError, "Extractor for `#{name}'` should"\
              " return ether boolean, or Fear::Option. Got `#{v.inspect}`"
          end
        end
      end

      def bindings(other)
        Fear::Option.match(extract(other)) do |m|
          m.some { |v| arguments_matcher.bindings([v].flatten) }
          m.none { EMPTY_ARRAY }
          m.case(false) { EMPTY_ARRAY }
          m.case(true) { EMPTY_ARRAY }
        end
      end

      def failure_reason(other)
        extract(other)
          .flat_map { |v| arguments_matcher.failure_reason([v].flatten) }
      end

      private def extract(other)
        Extractor.find_extractor(name).call(other)
      end
    end
  end
end
