module Fear
  module ForApi
    # Syntactic sugar for composition of  multiple monadic operations. It supports two such
    # operations - +flat_map+ and +map+. Any class providing them
    # is supported by +Fear.or+.
    #
    #     Fear.for(Fear.some(2), Fear.some(3)) do |a, b|
    #       a * b
    #     end #=> Fear.some(6)
    #
    # If one of operands is None, the result is None
    #
    #     Fear.for(Fear.some(2), Fear.none()) { |a, b| a * b } #=> Fear.none()
    #     Fear.for(Fear.none(), Fear.some(2)) { |a, b| a * b } #=> Fear.none()
    #
    # Lets look at first example:
    #
    #     Fear.for(Fear.some(2), Fear.some(3)) { |a, b| a * b }
    #
    # it is translated to:
    #
    #     Fear.some(2).flat_map do |a|
    #       Fear.some(3).map do |b|
    #         a * b
    #       end
    #     end
    #
    # It works with arrays as well
    #
    #     Fear.for([1, 2], [2, 3], [3, 4]) { |a, b, c| a * b * c }
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
    #     Fear.for(proc { Fear.none() }, proc { raise 'kaboom' } ) do |a, b|
    #       a * b
    #     end #=> Fear.none()
    #
    # It does not fail since `b` is not evaluated.
    # You can refer to previously defined monads from within lambdas.
    #
    #     maybe_user = find_user('Paul') #=> <#Option value=<#User ...>>
    #
    #     Fear.for(maybe_user, ->(user) { user.birthday }) do |user, birthday|
    #       "#{user.name} was born on #{birthday}"
    #     end #=> Fear.some('Paul was born on 1987-06-17')
    #
    # @param monads [{#map, #flat_map}]
    # @return [{#map, #flat_map}]
    #
    def for(*monads, &block)
      Fear::For.call(monads, &block)
    end
  end
end
