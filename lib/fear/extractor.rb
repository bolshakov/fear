require 'dry/struct'
require 'treetop'
require 'fear/extractor/grammar'
Treetop.load File.expand_path('extractor/grammar.treetop', __dir__)

module Fear
  # @api private
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
    autoload :ExtractorMatcher, 'fear/extractor/extractor_matcher'
    autoload :IdentifiedMatcher, 'fear/extractor/identified_matcher'
    autoload :IdentifierMatcher, 'fear/extractor/identifier_matcher'
    autoload :NamedArraySplatMatcher, 'fear/extractor/named_array_splat_matcher'
    autoload :NilMatcher, 'fear/extractor/nil_matcher'
    autoload :NumberMatcher, 'fear/extractor/number_matcher'
    autoload :StringMatcher, 'fear/extractor/string_matcher'
    autoload :TypedIdentifierMatcher, 'fear/extractor/typed_identifier_matcher'
    autoload :TypeMatcher, 'fear/extractor/type_matcher'

    ExtractorNotFound = Class.new(Error)

    @mutex = Mutex.new
    @registry = {}

    class << self
      # @param klass [Class, String]
      # @api private
      def find_extractor(klass)
        @registry.fetch(klass) do
          raise ExtractorNotFound, 'could not find extractor for ' + klass.inspect
        end
      end

      # Register extractor for given class
      # @!method register_extractor(*names, extractor)
      #   @param names [<Class, String>, Class, String] name of a class. You can also pass alias for the name
      #   @param extractor [Proc<any => Fear::Option>] proc taking any argument and returned Option
      #     of extracted value('s)
      #
      # @example
      #   register_extractor(Fear::Some, Fear.case(Fear::Some) { |some| some.get }.lift)
      #
      #   register_extractor(User, Fear.case(User) { |user|} [user.id, user.email] , )
      #
      # @example registering an alias. Alias should be CamelCased string
      #   register_extractor(Fear::Some, 'Some', Fear.case(Fear::Some) { |some| some.get }.lift)
      #
      #   # no you can extract Fear::Some's using Some alias
      #   m.case(Fear['Some(value : Integer)']) { |value:| value * 2 }
      #
      def register_extractor(*args)
        *keys, extractor = *args

        @mutex.synchronize do
          keys.map(&:to_s).uniq.each do |key|
            @registry[key] = extractor
          end
        end
        self
      end
    end

    # Multiple arguments extractor example
    register_extractor('Date', proc do |other|
      if other.class.name == 'Date'
        Fear.some([other.year, other.month, other.day])
      else
        Fear.none
      end
    end)
    # No argument boolean extractor example
    register_extractor('IsEven', proc { |int| int.is_a?(Integer) && int.even? })
    # Single argument extractor example
    register_extractor('Fear::Some', 'Some', Some::EXTRACTOR)
    register_extractor('Fear::None', 'None', NoneClass::EXTRACTOR)
    register_extractor('Fear::Right', 'Right', Right::EXTRACTOR)
    register_extractor('Fear::Left', 'Left', Left::EXTRACTOR)
    register_extractor('Fear::Success', 'Success', Success::EXTRACTOR)
    register_extractor('Fear::Failure', 'Failure', Failure::EXTRACTOR)
  end
end
