module Fear
  module ExtractorApi
    def [](pattern)
      Extractor::Pattern.new(pattern)
    end
  end
end
