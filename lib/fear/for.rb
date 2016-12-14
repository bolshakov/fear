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
  # You can refer to previously defined variables from within lambdas.
  #
  #     maybe_user = find_user('Paul') #=> <#Option value=<#User ...>>
  #
  #     For(user: maybe_user, birthday: -> { user.birthday }) do
  #       "#{user.name} was born on #{birthday}"
  #     end #=> Some('Paul was born on 1987-06-17')
  #
  class For
    require_relative 'for/evaluation_context'

    # @param variables [Hash{Symbol => any}]
    #
    def initialize(**variables)
      @variables = variables
      @evaluation_context = EvaluationContext.new
    end

    def call(&block)
      variable_name_and_monad, *tail = *variables
      execute(*variable_name_and_monad, tail, &block)
    end

    private

    attr_reader :variables
    attr_reader :evaluation_context

    def execute(variable_name, monad, monads, &block) # rubocop:disable Metrics/MethodLength
      if monads.empty?
        resolve(monad).map do |value|
          evaluation_context.assign(variable_name, value)
          evaluation_context.instance_exec(&block)
        end
      else
        resolve(monad).flat_map do |value|
          evaluation_context.assign(variable_name, value)
          variable_name_and_monad, *tail = *monads
          execute(*variable_name_and_monad, tail, &block)
        end
      end
    end

    def resolve(monad_or_proc)
      if monad_or_proc.respond_to?(:call)
        evaluation_context.instance_exec(&monad_or_proc)
      else
        monad_or_proc
      end
    end

    # Include this mixin to access convenient factory method for +For+.
    # @example
    #   include Fear::For::Mixin
    #
    #   For(a: Some(2), b: Some(3)) { a * b } #=> Some(6)
    #   For(a: Some(2), b: None()) { a * b }  #=> None()
    #
    #   For(a: -> { Some(2) }, b: -> { Some(3) }) do
    #     a * b
    #   end #=> Some(6)
    #
    #   For(a: -> { None() }, b: -> { fail }) do
    #     a * b
    #   end #=> None()
    #
    #   For(a: Right(2), b: Right(3)) { a * b } #=> Right(6)
    #   For(a: Right(2), b: Left(3)) { a * b }  #=> Left(3)
    #
    #   For(a: Success(2), b: Success(3)) { a * b }    #=> Success(3)
    #   For(a: Success(2), b: Failure(...)) { a * b }  #=> Failure(...)
    #
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
