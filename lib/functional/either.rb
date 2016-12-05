module Functional
  # Represents a value of one of two possible types (a disjoint union.)
  # An instance of `Either` is either an instance of `Left` or `Right`.
  #
  # A common use of `Either` is as an alternative to `Option` for dealing
  # with possible missing values.  In this usage, `None` is replaced
  # with a `Left` which can contain useful information.
  # `Right` takes the place of `Some`. Convention dictates
  # that `Left` is used for failure and `Right` is used for success.
  #
  # For example, you could use `Either<String, Fixnum>` to detect whether a
  # received input is a `String` or an `Fixnum`.
  #
  # @example
  #   in = Readline.readline('Type Either a string or an Int: ', true)
  #   result = begin
  #     Right(Integer(in))
  #   rescue ArgumentError
  #     Left(in)
  #   end
  #
  #   puts(
  #     result.reduce(
  #       -> (x) { "You passed me the Int: #{x}, which I will increment. #{x} + 1 = #{x+1}" },
  #       -> (x) { "You passed me the String: #{x}" }
  #     )
  #   )
  #
  # `Either` is right-biased, which means that `Right` is assumed to be the default case to
  # operate on. If it is `Left`, operations like `#map`, `#flat_map`, ... return the `Left` value
  # unchanged:
  #
  # @example
  #   Right(12).map { |_| _ * 2) #=> Right(24)
  #   Left(23).map { |_| _ * 2)  #=> Left(23)
  #
  # @see https://github.com/scala/scala/blob/2.12.x/src/library/scala/util/Either.scala
  #
  module Either
    include Dry::Equalizer(:value)
    include Functional

    def initialize(value)
      @value = value
    end

    attr_reader :value
    protected :value

    # @return [Boolean]
    def left?
      is_a?(Left)
    end

    # @return [Boolean]
    def right?
      is_a?(Right)
    end

    # Applies `reduce_left` if this is a `Left` or `reduce_right` if this is a `Right`.
    #
    # @example
    #   result = possibly_failing_operation()
    #   log(
    #     result.reduce(
    #       ->(ex) { "Operation failed with #{ex}" },
    #       ->(v) { "Operation produced value: #{v}" },
    #     )
    #   )
    #
    # @param reduce_left [Proc] the function to apply if this is a `Left`
    # @param reduce_right [Proc] the function to apply if this is a `Right`
    # @return [any] the results of applying the function
    #
    def reduce(reduce_left, reduce_right)
      case self
      when Left
        reduce_left.call(value)
      when Right
        reduce_right.call(value)
      end
    end

    # If this is a `Left`, then return the left value in `Right` or vice versa.
    #
    # @example
    #   left = Left("left")
    #   right = left.swap #=> Right("left")
    #
    def swap
      case self
      when Left
        Right(value)
      when Right
        Left(value)
      end
    end

    # Joins an `Either` through `Right`.
    #
    # This method requires that the right side of this `Either` is itself an
    # Either type.
    #
    # If this instance is a `Right<Either>` then the contained `Either`
    # will be returned, otherwise this value will be returned unmodified.
    #
    # @example
    #   Right(Right(12)).join_right      #=> Right(12)
    #   Right(Left("flower")).join_right #=> Left("flower")
    #   Left("flower").join_right        #=> Left("flower")
    #
    # This method, and `join_left`, are analogous to `Option#flatten`
    #
    # @return [Either]
    # @raise [TypeError] if `Right` does not contain `Either`.
    #
    def join_right
      case self
      when Left
        self
      when Right
        value.tap { |v| Utils.assert_type!(v, Either) }
      end
    end

    # Joins an `Either` through `Left`.
    #
    # This method requires that the left side of this `Either` is itself an
    # Either type.
    #
    # If this instance is a `Left<Either>` then the contained `Either`
    # will be returned, otherwise this value will be returned unmodified.
    #
    # @example
    #   Left(Right("flower")).join_left #=> Right("flower")
    #   Left(Left(12)).join_left        #=> Left(12)
    #   Right("daisy").join_left        #=> Right("daisy")
    #
    # This method, and `join_right`, are analogous to `Option#flatten`
    #
    # @return [Either]
    # @raise [TypeError] if `Right` does not contain `Either`.
    #
    def join_left
      case self
      when Left
        value.tap { |v| Utils.assert_type!(v, Either) }
      when Right
        self
      end
    end

    # Executes the given side-effecting block if this is a `Right`.
    #
    # @example
    #   Right(12).each { |x| puts x } # prints "12"
    #   Left(12).each { |x| puts x } # doesn't print
    #
    # @return [Either]
    #
    def each
      yield(value) if right?
      self
    end

    # Returns the value from this `Right` or the given argument if
    # this is a `Left`.
    #
    # @!method get_or_else(default)
    #   Returns the value from the `Right`, or default if this is a `Left`.
    #   @param default [any]
    #   @return [any]
    #
    # @!method get_or_else(&default)
    #   Returns the value from the `Right`, or result of evaluating a block
    #   if this is a `Left`.
    #   @return [any]
    #
    # @example
    #   Right(12).get_or_else(17) #=> 12
    #   Left(12).get_or_else(17) #=> 17
    #
    # @example lazy-evaluate default
    #   Right(12).get_or_else { 17 } #=> 12
    #   Left(12).get_or_else { 17 } #=> 17
    #
    def get_or_else(*args, &block)
      Utils.assert_arg_or_block!('get_or_else', *args, &block)

      case self
      when Left
        args.fetch(0) { yield }
      when Right
        value
      end
    end

    # Returns `true` if this is a `Right` and its value is equal to `other_value`
    # (as determined by `==`), returns `false` otherwise.
    #
    # @example
    #   # Returns true because value of Right is "something" which equals "something".
    #   Right("something").include?("something") #= true
    #
    #   # Returns false because value of Right is "something" which does not equal "anything".
    #   Right("something").include?("anything") #=> false
    #
    #   # Returns false because there is no value for Right.
    #   Left("something").include?("something") #=> false
    #
    # @param other_value [any] the element to test.
    # @return [Boolean] `true` if the option has an element that is equal
    #   (as determined by `==`) to `other_value`, `false` otherwise.
    #
    def include?(other_value)
      case self
      when Left
        false
      when Right
        value == other_value
      end
    end

    # Returns `true` if `Left` or returns the result of the application of
    # the given predicate to the `Right` value.
    #
    # @example
    #   Right(12).all? { |v| v > 10 } #=> true
    #   Right(7).all? { |v| v > 10 }  #=> false
    #   Left(12).all? { |v| v > 10 }  #=> true
    #
    # @return [Boolean]
    #
    def all?
      case self
      when Left
        true
      when Right
        yield(value)
      end
    end

    # Returns `false` if `Left` or returns the result of the application of
    # the given predicate to the `Right` value.
    #
    # @example
    #   Right(12).any? { |v| v > 10 } #=> true
    #   Right(7).any? { |v| v > 10 }  #=> false
    #   Left(12).any? { |v| v > 10 }  #=> false
    #
    # @return [Boolean]
    #
    def any?
      case self
      when Left
        false
      when Right
        yield(value)
      end
    end

    # Binds the given function across `Right`.
    #
    # @example
    #   Right(12).flat_map { |x| Left('ruby') } #=> Left('ruby')
    #   Left(12).flat_map { |x| Left('ruby') }  #=> Left(12)
    #
    # @return [Either]
    #
    def flat_map
      case self
      when Left
        self
      when Right
        yield(value).tap { |v| Utils.assert_type!(v, Either) }
      end
    end

    # Maps the block through `Right`.
    #
    # @example
    #   Right('ruby').map(&:length) #=> Right(4)
    #   Left('ruby').map(&:length) #=> Left('ruby')
    #
    # @return [Either]
    #
    def map
      case self
      when Left
        self
      when Right
        Right.new(yield(value))
      end
    end

    # Returns `None` if this is a `Left` or if the given predicate
    # does not hold for the right value, otherwise, returns `Some` of `Right`.
    #
    # @example
    #   Right(12).detect(-1, &:even?) #=> Right(12))
    #   Right(7).detect(-1, &:even?) #=> Left(-1)
    #   Left(12).detect(-1, &:even?) #=> Left(-1)
    #   Left(12).detect(-> { -1 }, &:even?) #=> Left(-1)
    #
    #
    # @param default [Proc, any]
    # @return [Either]
    #
    def detect(default)
      case self
      when Left
        Left(return_or_call_proc(default))
      when Right
        yield(value) ? self : Left(return_or_call_proc(default))
      end
    end

    # Returns a `Array` containing the `Right` value if it exists or an empty
    # `Array` if this is a `Left`.
    #
    # @example
    #   Right(12).to_a #=> [12]
    #   Left(12).to_a #=> []
    #
    # @return [(any)]
    #
    def to_a
      case self
      when Left
        []
      when Right
        [value]
      end
    end

    # Returns a `Some` containing the `Right` value if it exists or a
    # `None` if this is a `Left`.
    #
    # @example
    #   Right(12).to_option #=> Some(12)
    #   Left(12).to_option #=> None()
    #
    # @return [Option<any>]
    #
    def to_option
      case self
      when Left
        None()
      when Right
        Some(value)
      end
    end

    private

    def return_or_call_proc(value)
      if value.respond_to?(:call)
        value.call
      else
        value
      end
    end
  end
end
