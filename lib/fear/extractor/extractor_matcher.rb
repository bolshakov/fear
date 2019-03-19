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

      def defined_at?(other)
        Fear::Option.match(extract(other)) do |m|
          m.some { |v| arguments_matcher.defined_at?(v) }
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
          m.some { |v| arguments_matcher.bindings(v) }
          m.none { EMPTY_ARRAY }
          m.case(false) { EMPTY_ARRAY }
          m.case(true) { EMPTY_ARRAY }
        end
      end

      def failure_reason(other)
        Fear::Option.match(extract(other)) do |m|
          m.some { |v| arguments_matcher.failure_reason(v) }
          m.none { Fear.none }
          m.case(false) { super }
          m.case(true) { Fear.none }
        end
      end

      private def extract(other)
        Extractor.find_extractor(name).call(other)
      end
    end
  end
end
