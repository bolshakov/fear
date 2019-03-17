require 'ostruct'

module Fear
  module Extractor
    # @abstract abstract matcher to inherit from.
    class Matcher < OpenStruct
      class And < Matcher
        def initialize(matcher1, matcher2)
          @matcher1 = matcher1
          @matcher2 = matcher2
        end
        attr_reader :matcher1, :matcher2

        def defined_at?(arg)
          matcher1.defined_at?(arg) && matcher2.defined_at?(arg)
        end

        def bindings(arg)
          matcher1.bindings(arg).merge(matcher2.bindings(arg))
        end

        def failure_reason(arg)
          if matcher1.defined_at?(arg)
            if matcher2.defined_at?(arg)
              Fear.none
            else
              matcher2.failure_reason(arg)
            end
          else
            matcher1.failure_reason(arg)
          end
        end
      end

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
