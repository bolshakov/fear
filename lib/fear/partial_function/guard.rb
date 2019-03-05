module Fear
  module PartialFunction
    # @api private
    class Guard
      class << self
        # @param conditions [<#===, Symbol>]
        # @return [Fear::PartialFunction::Guard]
        def and(conditions)
          conditions.inject(Utils::UNDEFINED) do |guard, condition|
            if guard == Utils::UNDEFINED
              new(condition)
            else
              guard.and(new(condition))
            end
          end
        end

        # @param conditions [<#===, Symbol>]
        # @return [Fear::PartialFunction::Guard]
        def or(conditions)
          conditions.inject(Utils::UNDEFINED) do |acc, condition|
            if acc == Utils::UNDEFINED
              new(condition)
            else
              acc.or(new(condition))
            end
          end
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

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def and(other)
        GuardAnd.new(@condition, other)
      end

      # @param other [Fear::PartialFunction::Guard]
      # @return [Fear::PartialFunction::Guard]
      def or(other)
        GuardOr.new(@condition, other)
      end

      # @param arg [any]
      # @return [Boolean]
      def ===(arg)
        @condition === arg
      end
    end
  end
end
