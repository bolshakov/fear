require 'dry/struct'
require 'treetop'
require 'fear/extractor/grammar'
Treetop.load File.expand_path('extractor/grammar.treetop', __dir__)

module Fear
  module Extractor
    module Types
      include Dry::Types.module
    end

    autoload :Pattern, 'fear/extractor/pattern'
    autoload :Matcher, 'fear/extractor/matcher'

    autoload :AnonymousArraySplatMatcher, 'fear/extractor/anonymous_array_splat_matcher'
    autoload :AnyMatcher, 'fear/extractor/any_matcher'
    autoload :ArrayHeadMatcher, 'fear/extractor/array_head_matcher'
    autoload :ArrayMatcher, 'fear/extractor/array_matcher'
    autoload :ArraySplatMatcher, 'fear/extractor/array_splat_matcher'
    autoload :BooleanMatcher, 'fear/extractor/boolean_matcher'
    autoload :EmptyListMatcher, 'fear/extractor/empty_list_matcher'
    autoload :IdentifierMatcher, 'fear/extractor/identifier_matcher'
    autoload :NamedArraySplatMatcher, 'fear/extractor/named_array_splat_matcher'
    autoload :NilMatcher, 'fear/extractor/nil_matcher'
    autoload :NumberMatcher, 'fear/extractor/number_matcher'
    autoload :StringMatcher, 'fear/extractor/string_matcher'

    class TypeMatcher < Matcher
      attribute :class_name, Types::Strict::String

      def defined_at?(other)
        Object.const_get(class_name) === other
      end
    end

    class TypedIdentifierMatcher < Matcher
      attribute :identifier, IdentifierMatcher
      attribute :type, TypeMatcher

      def defined_at?(other)
        type.defined_at?(other)
      end

      def bindings(other)
        { identifier.name => other }
      end
    end

    class IdentifiedMatcher < Matcher
      attribute :identifier, IdentifierMatcher
      attribute :matcher, Matcher

      def defined_at?(other)
        matcher.defined_at?(other)
      end

      def bindings(other)
        { identifier.name => other }.merge(matcher.bindings(other))
      end
    end
  end
end
