module Functional
  # This class provides syntactic sugar for composition of
  # multiple monadic operations. It supports two such
  # operations - `flat_map` and `map`. Any class providing them
  # is supported by `For`.
  #
  # @example Option
  #   For(a: Some(2), b: Some(3)) { a * b } #=> Some(6)
  #   # If one of operands is None, the result is None
  #   For(a: Some(2), b: None()) { a * b } #=> None()
  #   For(a: None(), b: Some(2)) { a * b } #=> None()
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
  class For
    # Context of block evaluation. It respond to passed locals.
    #
    # @example
    #   context = EvaluationContext.new(foo: 'bar')
    #   context.foo #=> 'bar'
    #
    class EvaluationContext < BasicObject
      # @param locals [Hash{Symbol => any}]
      #
      def initialize(locals)
        @locals = locals
      end

      def method_missing(name, *args, &block)
        if @locals.include?(name) && args.empty? && block.nil?
          @locals[name]
        else
          super
        end
      end

      def respond_to_missing?(name, _)
        @locals.key?(name)
      end
    end
    private_constant(:EvaluationContext)

    # @param variables [Hash{Symbol => any}]
    #
    def initialize(**variables)
      @variables = variables
    end
    attr_reader :variables

    def call(&block)
      variable_name_and_monad, *tail = *variables
      execute({}, *variable_name_and_monad, tail, &block)
    end

    private

    def execute(locals, variable_name, monad, monads, &block)
      if monads.empty?
        monad.map do |value|
          EvaluationContext.new(locals.merge(variable_name => value)).instance_eval(&block)
        end
      else
        monad.flat_map do |value|
          variable_name_and_monad, *tail = *monads
          execute(locals.merge(variable_name => value), *variable_name_and_monad, tail, &block)
        end
      end
    end

    module Mixin
      # @param locals [Hash{Symbol => {#map, #flat_map}}]
      # @return [{#map, #flat_map}]
      #
      def For(**locals, &block)
        For.new(**locals).call(&block)
      end
    end
  end
end
