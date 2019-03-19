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
        @defined_at_matcher = build_defined_at_matcher
        @find_bindings = build_bindings_finder
      end
      attr_reader :extractor, :defined_at_matcher, :find_bindings
      private :extractor
      private :defined_at_matcher
      private :find_bindings

      private def build_defined_at_matcher
        Fear::Option.matcher do |m|
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

      private def build_bindings_finder
        Fear::Option.matcher do |m|
          m.some { |v| arguments_matcher.bindings(v) }
          m.none { EMPTY_ARRAY }
          m.case(false) { EMPTY_ARRAY }
          m.case(true) { EMPTY_ARRAY }
        end
      end

      def defined_at?(other)
        extracted = extractor.call(other)
        build_defined_at_matcher.call(extracted)
      end

      def bindings(other)
        extracted = extractor.call(other)
        find_bindings.call(extracted)
      end

      def failure_reason(other)
        extracted = extractor.call(other)

        Fear::Option.match(extracted) do |m|
          m.some { |v| arguments_matcher.failure_reason(v) }
          m.none { Fear.none }
          m.case(false) { super }
          m.case(true) { Fear.none }
        end
      end
    end
  end
end
