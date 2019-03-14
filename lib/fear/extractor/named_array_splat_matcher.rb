module Fear
  module Extractor
    class NamedArraySplatMatcher < ArraySplatMatcher
      attribute :name, Types::Strict::Symbol

      def bindings(other)
        { name => other }
      end
    end
  end
end
