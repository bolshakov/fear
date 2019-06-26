# typed: false
module Fear
  module ExtractorApi
    # Allows to pattern match and extract matcher variables
    #
    # @param pattern [String]
    # @return [Extractor::Pattern]
    # @note it is not intended to be used by itself, rather then with partial functions
    def [](pattern)
      Extractor::Pattern.new(pattern)
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
      Extractor.register_extractor(*args)
    end
  end
end
