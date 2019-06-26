# typed: false
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
        super(attributes)
      end
      attr_reader :input_position, :input
      private :input
      private :input_position

      def call(arg)
        call_or_else(arg, &PartialFunction::EMPTY)
      end

      def and(other)
        And.new(self, other)
      end

      # @param arg [any]
      # @yield [arg] if function not defined
      def call_or_else(arg)
        if defined_at?(arg)
          bindings(arg)
        else
          yield arg
        end
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
