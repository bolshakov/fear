module Fear
  module Extractor
    class EmptyListMatcher < Matcher
      attribute :index, Types::Strict::Integer

      def defined_at?(other)
        other.empty?
      end

      def bindings(_other)
        Dry::Core::Constants::EMPTY_HASH
      end
    end
  end
end
