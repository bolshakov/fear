module Fear
  # This class provides syntactic sugar for composition of
  # multiple monadic operations. It supports two such
  # operations - +flat_map+ and +map+. Any class providing them
  # is supported by +For+.
  #
  #     For(Some(2), Some(3)) do |a, b|
  #       a * b
  #     end #=> Some(6)
  #
  # If one of operands is None, the result is None
  #
  #     For(Some(2), None()) { |a, b| a * b } #=> None()
  #     For(None(), Some(2)) { |a, b| a * b } #=> None()
  #
  # Lets look at first example:
  #
  #     For(Some(2), Some(3)) { |a, b| a * b }
  #
  # it is translated to:
  #
  #     Some(2).flat_map do |a|
  #       Some(3).map do |b|
  #         a * b
  #       end
  #     end
  #
  # It works with arrays as well
  #
  #     For([1, 2], [2, 3], [3, 4]) { |a, b, c| a * b * c }
  #       #=> [6, 8, 9, 12, 12, 16, 18, 24]
  #
  # it is translated to:
  #
  #     [1, 2].flat_map do |a|
  #       [2, 3].flat_map do |b|
  #         [3, 4].map do |c|
  #           a * b * c
  #         end
  #       end
  #     end
  #
  # If you pass lambda instead of monad, it would be evaluated
  # only on demand.
  #
  #     For(proc { None() }, proc { fail 'kaboom' } ) do |a, b|
  #       a * b
  #     end #=> None()
  #
  # It does not fail since `b` is not evaluated.
  # You can refer to previously defined monads from within lambdas.
  #
  #     maybe_user = find_user('Paul') #=> <#Option value=<#User ...>>
  #
  #     For(maybe_user, ->(user) { user.birthday }) do |user, birthday|
  #       "#{user.name} was born on #{birthday}"
  #     end #=> Some('Paul was born on 1987-06-17')
  #
  module For
    module_function

    # @param monads [<Fear::Option, Fear::Either, Fear::Try, Proc>]
    #
    def call(monads, inner_values = [], &block)
      head, *tail = *monads

      if tail.length.zero?
        map(head, inner_values, &block)
      else
        flat_map(head, tail, inner_values, &block)
      end
    end

    private def map(head, inner_values)
      resolve(head, inner_values).map do |x|
        yield(*inner_values, x)
      end
    end

    private def flat_map(head, tail, inner_values, &block)
      resolve(head, inner_values).flat_map do |x|
        call(tail, inner_values + [x], &block)
      end
    end

    private def resolve(monad_or_proc, inner_values)
      if monad_or_proc.respond_to?(:call)
        monad_or_proc.call(*inner_values)
      else
        monad_or_proc
      end
    end

    # Include this mixin to access convenient factory method for +For+.
    # @example
    #   include Fear::For::Mixin
    #
    #   For(Some(2), Some(3)) { |a, b| a * b } #=> Some(6)
    #   For(Some(2), None()) { |a, b| a * b }  #=> None()
    #
    #   For(proc { Some(2) }, proc { Some(3) }) do |a, b|
    #     a * b
    #   end #=> Some(6)
    #
    #   For(proc { None() }, proc { fail }) do |a, b|
    #     a * b
    #   end #=> None()
    #
    #   For(Right(2), Right(3)) { |a, b| a * b } #=> Right(6)
    #   For(Right(2), Left(3)) { |a, b| a * b }  #=> Left(3)
    #
    #   For(Success(2), Success(3)) { |a| a * b } #=> Success(3)
    #   For(Success(2), Failure(...)) { |a, b| a * b }  #=> Failure(...)
    #
    module Mixin
      # @param monads [Hash{Symbol => {#map, #flat_map}}]
      # @return [{#map, #flat_map}]
      #
      def For(*monads, &block)
        For.call(monads, &block)
      end
    end
  end
end
