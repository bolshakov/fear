# frozen_string_literal: true

module Fear
  module PartialFunction
    # Guard represents PartialFunction guardian
    #
    # @api private
    class Guard
      class << self
        # Optimized version for combination of two guardians
        # Two guarding is a very common situation. For example checking for Some, and checking
        # a value withing container.
        #
        def and2(c1, c2)
          Guard::And.new(c1, c2)
        end

        def and3(c1, c2, c3)
          Guard::And3.new(c1, c2, c3)
        end

        def and1(c)
          c
        end

        # @param conditions [<#===>]
        # @return [Fear::PartialFunction::Guard]
        def and(conditions)
          case conditions.size
          when 1 then and1(*conditions)
          when 2 then and2(*conditions)
          when 3 then and3(*conditions)
          when 0 then Any
          else
            head, *tail = conditions
            tail.reduce(new(head)) { |acc, condition| acc.and(new(condition)) }
          end
        end

        # @param conditions [<#===>]
        # @return [Fear::PartialFunction::Guard]
        def or(conditions)
          return Any if conditions.empty?

          head, *tail = conditions
          tail.reduce(new(head)) { |acc, condition| acc.or(new(condition)) }
        end
      end

      # @param condition [#===]
      def initialize(condition)
        @condition = condition
      end
      attr_reader :condition
      private :condition

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def and(other)
        Guard::And.new(condition, other)
      end

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def or(other)
        Guard::Or.new(condition, other)
      end

      # @param arg [any]
      # @return [Boolean]
      def ===(arg)
        condition === arg
      end
    end
  end
end
