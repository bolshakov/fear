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
  end
end
