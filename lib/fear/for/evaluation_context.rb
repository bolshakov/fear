module Fear
  # This class provides syntactic sugar for composition of
  # multiple monadic operations. It supports two such
  # operations - +flat_map+ and +map+. Any class providing them
  # is supported by +For+.
  #
  #     For(a: Some(2), b: Some(3)) { a * b } #=> Some(6)
  #
  # If one of operands is None, the result is None
  #
  #     For(a: Some(2), b: None()) { a * b } #=> None()
  #     For(a: None(), b: Some(2)) { a * b } #=> None()
  #
  # Lets look at first example:
  #
  #     For(a: Some(2), b: Some(3)) { a * b }
  #
  # would be translated to:
  #
  #     Some(2).flat_map do |a|
  #       Some(3).map do |b|
  #         a * b
  #       end
  #     end
  #
  # It works with arrays as well
  #
  #     For(a: [1, 2], b: [2, 3], c: [3, 4]) { a * b * c }
  #       #=> [6, 8, 9, 12, 12, 16, 18, 24]
  #
  # would be translated to:
  #
  #     [1, 2].flat_map do |a|
  #       [2, 3].flat_map do |b|
  #         [3, 4].map do |c|
  #           a * b * c
  #         end
  #       end
  #     end
  #
  # If you pass lambda as a variable value, it would be evaluated
  # only on demand.
  #
  #     For(a: -> { None() }, b: -> { fail 'kaboom' } ) { a * b }
  #       #=> None()
  #
  # It does not fail since `b` is not evaluated.
  # You can mix and match lambdas and variables.
  #
  #     For(a: -> None(), b: -> { fail 'kaboom' } ) { a * b }
  #       #=> None()
  #
  class For
    # Context of block evaluation. It respond to passed locals.
    #
    # @example
    #   context = EvaluationContext.new
    #   context.assign(:foo, 'bar')
    #   context.foo #=> 'bar'
    #
    class EvaluationContext < BasicObject
      include ::Fear::Option::Mixin
      include ::Fear::Either::Mixin
      include ::Fear::Try::Mixin

      def initialize(outer_context)
        @assigns = {}
        @outer_context = outer_context
      end

      def __assign__(name, value)
        @assigns[name] = value
      end

      def method_missing(name, *args, &block)
        if @assigns.include?(name) && args.empty? && block.nil?
          @assigns[name]
        elsif @outer_context.respond_to?(name)
          @outer_context.__send__(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, _)
        @assigns.key?(name) && args.empty? && block.nil?
      end
    end
    private_constant(:EvaluationContext)
  end
end
