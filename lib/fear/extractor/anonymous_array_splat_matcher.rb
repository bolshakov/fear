module Fear
  module Extractor
    # Match against array splat, E.g. `[1, 2, *]` or `[1, 2, *_]`
    #
    class AnonymousArraySplatMatcher < ArraySplatMatcher
      def bindings(_)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
