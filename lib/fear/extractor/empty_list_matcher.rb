module Fear
  module Extractor
    # Match only if array is empty
    #
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
