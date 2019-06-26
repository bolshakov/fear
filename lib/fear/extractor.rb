# typed: false
require 'treetop'
require 'fear/extractor/grammar'
Treetop.load File.expand_path('extractor/grammar.treetop', __dir__)

module Fear
  # @api private
  module Extractor
    autoload :Pattern, 'fear/extractor/pattern'
    autoload :Matcher, 'fear/extractor/matcher'

    autoload :AnonymousArraySplatMatcher, 'fear/extractor/anonymous_array_splat_matcher'
    autoload :AnyMatcher, 'fear/extractor/any_matcher'
    autoload :ArrayHeadMatcher, 'fear/extractor/array_head_matcher'
    autoload :ArrayMatcher, 'fear/extractor/array_matcher'
    autoload :ArraySplatMatcher, 'fear/extractor/array_splat_matcher'
    autoload :EmptyListMatcher, 'fear/extractor/empty_list_matcher'
    autoload :ExtractorMatcher, 'fear/extractor/extractor_matcher'
    autoload :IdentifierMatcher, 'fear/extractor/identifier_matcher'
    autoload :NamedArraySplatMatcher, 'fear/extractor/named_array_splat_matcher'
    autoload :TypedIdentifierMatcher, 'fear/extractor/typed_identifier_matcher'
    autoload :ValueMatcher, 'fear/extractor/value_matcher'

    ExtractorNotFound = Class.new(Error)

    @mutex = Mutex.new
    @registry = PartialFunction::EMPTY

    EXTRACTOR_NOT_FOUND = proc do |klass|
      raise ExtractorNotFound, 'could not find extractor for ' + klass.inspect
    end

    class << self
      # @param klass [Class, String]
      # @api private
      def find_extractor(klass)
        @registry.call_or_else(klass, &EXTRACTOR_NOT_FOUND)
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
          keys.uniq.each do |key|
            @registry = BUILD_EXTRACTOR.call(key, extractor).or_else(@registry)
          end
        end
        self
      end

      BUILD_EXTRACTOR = proc do |key, extractor|
        Fear.matcher do |m|
          case key
          when String
            m.case(Module, ->(lookup) { lookup.to_s == key }) { extractor }
            m.case(String, key) { extractor }
          when Module
            m.case(Module, ->(lookup) { lookup <= key }) { extractor }
            m.case(String, key.to_s) { extractor }
          else
            m.case(key) { extractor } # may it be useful to register other types of keys? lambda?
          end
        end
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
    register_extractor(::Struct, Fear.case(::Struct, &:to_a).lift)
    # No argument boolean extractor example
    register_extractor('IsEven', proc do |int|
      if int.is_a?(Integer) && int.even?
        Fear.some([])
      else
        Fear.none
      end
    end)
    # Single argument extractor example
    register_extractor('Fear::Some', 'Some', Some::EXTRACTOR)
    register_extractor('Fear::None', 'None', NoneClass::EXTRACTOR)
    register_extractor('Fear::Right', 'Right', Right::EXTRACTOR)
    register_extractor('Fear::Left', 'Left', Left::EXTRACTOR)
    register_extractor('Fear::Success', 'Success', Success::EXTRACTOR)
    register_extractor('Fear::Failure', 'Failure', Failure::EXTRACTOR)
  end
end
