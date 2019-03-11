module Fear
  module PartialFunction
    # Guard represents PartialFunction guardian
    #
    # @api private
    class Guard
      autoload :And, 'fear/partial_function/guard/and'
      autoload :And3, 'fear/partial_function/guard/and3'
      autoload :Or, 'fear/partial_function/guard/or'

      class << self
        # Optimized version for combination of two guardians
        # Two guarding is a very common situation. For example checking for Some, and checking
        # a value withing contianer.
        #
        def and2(c1, c2)
          Guard::And.new(
            (c1.is_a?(Symbol) ? c1.to_proc : c1),
            (c2.is_a?(Symbol) ? c2.to_proc : c2),
          )
        end

        def and3(c1, c2, c3)
          Guard::And3.new(
            (c1.is_a?(Symbol) ? c1.to_proc : c1),
            (c2.is_a?(Symbol) ? c2.to_proc : c2),
            (c3.is_a?(Symbol) ? c3.to_proc : c3),
          )
        end

        def and1(c)
          c.is_a?(Symbol) ? c.to_proc : c
        end

        # @param conditions [<#===, Symbol>]
        # @return [Fear::PartialFunction::Guard]
        def and(conditions)
          case conditions.size
          when 1 then and1(*conditions)
          when 2 then and2(*conditions)
          when 3 then and3(*conditions)
          when 0 then Any
          else
            head, *tail = conditions
            tail.inject(new(head)) { |acc, condition| acc.and(new(condition)) }
          end
        end

        # @param conditions [<#===, Symbol>]
        # @return [Fear::PartialFunction::Guard]
        def or(conditions)
          return Any if conditions.empty?

          head, *tail = conditions
          tail.inject(new(head)) { |acc, condition| acc.or(new(condition)) }
        end
      end

      # @param condition [<#===, Symbol>]
      def initialize(condition)
        @condition =
          if condition.is_a?(Symbol)
            condition.to_proc
          else
            condition
          end
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
