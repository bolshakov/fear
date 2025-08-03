# frozen_string_literal: true

module Fear
  module Either
    # Projects an `Either` into a `Left`.
    # @see Fear::Either#left
    #
    class LeftProjection
      prepend Fear::RightBiased::Interface

      # @!attribute either
      #   @return [Fear::Either]
      attr_reader :either
      protected :either

      # @param either [Fear::Either]
      def initialize(either)
        @either = either
      end

      # Returns +true+ if +Fear::Left+ has an element that is equal
      # (as determined by +==+) to +other_value+, +false+ otherwise.
      # @param [Object]
      # @return [Boolean]
      # @example
      #   Fear.left(17).left.include?(17)           #=> true
      #   Fear.left(17).left.include?(7)            #=> false
      #   Fear.right('undefined').left.include?(17) #=> false
      #
      def include?(other_value)
        case either
        in Fear::Left(x)
          x == other_value
        in Fear::Right
          false
        end
      end

      # Returns the value from this +Fear::Left+ or evaluates the given
      # default argument if this is a +Fear::Right+.
      #
      # @overload get_or_else(&default)
      #   @yieldreturn [Object]
      #   @return [Object]
      #   @example
      #     Fear.right(42).left.get_or_else { 24/2 }         #=> 12
      #     Fear.left('undefined').left.get_or_else { 24/2 } #=> 'undefined'
      #
      # @overload get_or_else(default)
      #   @return [Object]
      #   @example
      #     Fear.right(42).left.get_or_else(12)         #=> 12
      #     Fear.left('undefined').left.get_or_else(12) #=> 'undefined'
      def get_or_else(*args)
        case either
        in Fear::Left(value)
          value
        in Fear::Right
          args.fetch(0) { yield }
        end
      end

      # Performs the given block if this is a +Fear::Left+.
      #
      # @yieldparam [Object] value
      # @yieldreturn [void]
      # @return [Fear::Either] itself
      # @example
      #   Fear.right(17).left.each do |value|
      #     puts value
      #   end #=> does nothing
      #
      #   Fear.left('undefined').left.each do |value|
      #     puts value
      #   end #=> prints "nothing"
      def each
        case either
        in Fear::Left(value)
          yield(value)
          either
        in Fear::Right
          either
        end
      end
      alias_method :apply, :each

      # Maps the block argument through +Fear::Left+.
      #
      # @yieldparam [Object] value
      # @yieldreturn [Fear::Either]
      # @example
      #   Fear.left(42).left.map { _1/2 }   #=> Fear.left(24)
      #   Fear.right(42).left.map { _1/2 }  #=> Fear.right(42)
      #
      def map
        case either
        in Fear::Left(value)
          Fear.left(yield(value))
        in Fear::Right
          either
        end
      end

      # Returns the given block applied to the value from this +Fear::Left+
      # or returns this if this is a +Fear::Right+.
      #
      # @yieldparam [Object] value
      # @yieldreturn [Fear::Either]
      # @return [Fear::Either]
      #
      # @example
      #   Fear.left(12).left.flat_map { Fear.left(_1 * 2) }  #=> Fear.left(24)
      #   Fear.left(12).left.flat_map { Fear.right(_1 * 2) } #=> Fear.right(24)
      #   Fear.right(12).left.flat_map { Fear.left(_1 * 2) } #=> Fear.right(12)
      #
      def flat_map
        case either
        in Fear::Left(value)
          yield(value)
        in Fear::Right
          either
        end
      end

      # Returns an +Fear::Some+ containing the +Fear::Left+ value or a +Fear::None+ if
      # this is a +Fear::Right+.
      # @return [Fear::Option]
      # @example
      #   Fear.left(42).left.to_option   #=> Fear.some(42)
      #   Fear.right(42).left.to_option  #=> Fear.none
      #
      def to_option
        case either
        in Fear::Left(value)
          Fear.some(value)
        in Fear::Right
          Fear.none
        end
      end

      # Returns an array containing the +Fear::Left+ value or an empty array if
      # this is a +Fear::Right+.
      #
      # @return [Array]
      # @example
      #   Fear.left(42).left.to_a   #=> [42]
      #   Fear.right(42).left.to_a  #=> []
      #
      def to_a
        case either
        in Fear::Left(value)
          [value]
        in Fear::Right
          []
        end
      end

      # Returns +false+ if +Fear::Right+ or returns the result of the
      # application of the given predicate to the +Fear::Light+ value.
      #
      # @yieldparam [Object] value
      # @yieldreturn [Boolean]
      # @return [Boolean]
      # @example
      #   Fear.left(12).left.any? { |v| v > 10 }  #=> true
      #   Fear.left(7).left.any? { |v| v > 10 }   #=> false
      #   Fear.right(12).left.any? { |v| v > 10 } #=> false
      #
      def any?(&predicate)
        case either
        in Fear::Left(value)
          predicate.call(value)
        in Fear::Right
          false
        end
      end

      # Returns +Fear::Right+ of value if the given predicate
      # does not hold for the left value, otherwise, returns +Fear::Left+.
      #
      # @yieldparam value [Object]
      # @yieldreturn [Boolean]
      # @return [Fear::Either]
      # @example
      #   Fear.left(12).left.select(&:even?)   #=> Fear.left(12)
      #   Fear.left(7).left.select(&:even?)    #=> Fear.right(7)
      #   Fear.right(12).left.select(&:even?)  #=> Fear.right(12)
      #   Fear.right(7).left.select(&:even?)   #=> Fear.right(7)
      #
      def select(&predicate)
        case either
        in Fear::Right
          either
        in Fear::Left(value) if predicate.call(value)
          either
        in Fear::Left
          either.swap
        end
      end

      # Returns +Fear::None+ if this is a +Fear::Right+ or if the given predicate
      # does not hold for the left value, otherwise, returns a +Fear::Left+.
      #
      # @yieldparam value [Object]
      # @yieldreturn [Boolean]
      # @return [Fear::Option<Fear::Either>]
      # @example
      #   Fear.left(12).left.find(&:even?) #=> #<Fear::Some value=#<Fear::Left value=12>>
      #   Fear.left(7).left.find(&:even?)  #=> #<Fear::None>
      #   Fear.right(12).left.find(&:even) #=> #<Fear::None>
      #
      def find(&predicate)
        case either
        in Fear::Left(value) if predicate.call(value)
          Fear.some(either)
        in Fear::Either
          Fear.none
        end
      end
      alias_method :detect, :find

      # @param other [Object]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) && other.either == either
      end

      private def left_class
        Fear::Right
      end

      private def right_class
        Fear::Left
      end
    end
  end
end
