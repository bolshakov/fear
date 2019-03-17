require 'ostruct'

module Fear
  module Extractor
    # @abstract abstract matcher to inherit from.
    class Matcher < OpenStruct
      autoload :And, 'fear/extractor/matcher/and'

      EMPTY_HASH = {}.freeze
      EMPTY_ARRAY = [].freeze

      # @param node [Fear::Extractor::Grammar::Node]
      def initialize(node:, **attributes)
        @input = node.input
        @input_position = node.interval.first
        super(**attributes)
      end
      attr_reader :input_position, :input
      private :input
      private :input_position

      # Checks if matcher match against provided argument
      # @param other [any]
      # @return [Boolean]
      def defined_at?(other)
        value === other
      end

      # @param arg [any]
      # @return [any] Calls this partial function with the given argument when it
      #   is contained in the function domain.
      # @raise [MatchError] when this partial function is not defined.
      def call(arg)
        if defined_at?(arg)
          bindings(arg)
        else
          EMPTY_HASH
        end
      end

      def and(other)
        And.new(self, other)
      end

      # Extracts binding from matcher
      # @param arg [any]
      # @return [Hash<Symbol => any>]
      protected def bindings(_arg)
        EMPTY_HASH
      end

      # Shows why matcher has failed. Use it for debugging.
      # @example
      #   Fear['[1, 2, _]'].failure_reason([1, 3, 4])
      #   # it will show that the second element hasn't match
      #
      def failure_reason(other)
        if defined_at?(other)
          Fear.none
        else
          Fear.some("Expected `#{other.inspect}` to match:\n#{input}\n#{'~' * input_position}^")
        end
      end
    end
  end
end
