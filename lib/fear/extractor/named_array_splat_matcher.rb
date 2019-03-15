module Fear
  module Extractor
    # Match against array splat, and capture rest of an array
    # E.g. +[1, 2, *tail]+
    #
    class NamedArraySplatMatcher < ArraySplatMatcher
      attribute :name, Types::Strict::Symbol

      def bindings(other)
        { name => other }
      end
    end
  end
end
