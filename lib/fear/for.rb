module Fear
  # @api private
  # @see Fear.for
  module For
    module_function # rubocop: disable Style/AccessModifierDeclarations

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
    #   For(Fear.some(2), Fear.some(3)) { |a, b| a * b } #=> Fear.some(6)
    #   For(Fear.some(2), Fear.none()) { |a, b| a * b }  #=> Fear.none()
    #
    #   For(proc { Fear.some(2) }, proc { Fear.some(3) }) do |a, b|
    #     a * b
    #   end #=> Fear.some(6)
    #
    #   For(proc { Fear.none() }, proc { raise }) do |a, b|
    #     a * b
    #   end #=> Fear.none()
    #
    #   For(Fear.right(2), Fear.right(3)) { |a, b| a * b } #=> Fear.right(6)
    #   For(Fear.right(2), Fear.left(3)) { |a, b| a * b }  #=> Fear.left(3)
    #
    #   For(Fear.success(2), Fear.success(3)) { |a| a * b } #=> Fear.success(3)
    #   For(Fear.success(2), Fear.failure(...)) { |a, b| a * b }  #=> Fear.failure(...)
    #
    module Mixin
      # @param monads [{#map, #flat_map}]
      # @return [{#map, #flat_map}]
      #
      def For(*monads, &block)
        Fear.for(*monads, &block)
      end
    end
  end
end
