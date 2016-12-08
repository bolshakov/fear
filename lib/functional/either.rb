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
  # @example #map
  #   Right(12).map { |_| _ * 2) #=> Right(24)
  #   Left(23).map { |_| _ * 2)  #=> Left(23)
  #
  # @example #get_or_else
  #   Right(12).get_or_else(17) #=> 12
  #   Left(12).get_or_else(17) #=> 17
  #
  #   Right(12).get_or_else { 17 } #=> 12
  #   Left(12).get_or_else { 17 } #=> 17
  #
  # @example #include?
  #   # Returns true because value of Right is "something" which equals "something".
  #   Right("something").include?("something") #= true
  #
  #   # Returns false because value of Right is "something" which does not equal "anything".
  #   Right("something").include?("anything") #=> false
  #
  #   # Returns false because there is no value for Right.
  #   Left("something").include?("something") #=> false
  #
  # @example #each
  #   Right(12).each { |x| puts x } # prints "12"
  #   Left(12).each { |x| puts x } # doesn't print
  #
  # @example #map
  #   Right('ruby').map(&:length) #=> Right(4)
  #   Left('ruby').map(&:length) #=> Left('ruby')
  #
  # @example #flat_map
  #   Right(12).flat_map { |x| Left('ruby') } #=> Left('ruby')
  #   Left(12).flat_map { |x| Left('ruby') }  #=> Left(12)
  #
  # @example #detect
  #   Right(12).detect(-1, &:even?) #=> Right(12))
  #   Right(7).detect(-1, &:even?) #=> Left(-1)
  #   Left(12).detect(-1, &:even?) #=> Left(-1)
  #   Left(12).detect(-> { -1 }, &:even?) #=> Left(-1)
  #
  # @example #to_a
  #   Right(12).to_a #=> [12]
  #   Left(12).to_a #=> []
  #
  # @example #to_option
  #   Right(12).to_option #=> Some(12)
  #   Left(12).to_option #=> None()
  #
  # @example #any?
  #   Right(12).any? { |v| v > 10 } #=> true
  #   Right(7).any? { |v| v > 10 }  #=> false
  #   Left(12).any? { |v| v > 10 }  #=> false
  #
  # @example #swap
  #   left = Left("left")
  #   right = left.swap #=> Right("left")
  #
  # @example #reduce
  #   result = possibly_failing_operation()
  #   log(
  #     result.reduce(
  #       ->(ex) { "Operation failed with #{ex}" },
  #       ->(v) { "Operation produced value: #{v}" },
  #     )
  #   )
  #
  # @example #join_right
  #   Right(Right(12)).join_right      #=> Right(12)
  #   Right(Left("flower")).join_right #=> Left("flower")
  #   Left("flower").join_right        #=> Left("flower")
  #   Left(Right("flower")).join_right #=> Left(Right("flower"))
  #
  # @example #join_left
  #   Left(Right("flower")).join_left #=> Right("flower")
  #   Left(Left(12)).join_left        #=> Left(12)
  #   Right("daisy").join_left        #=> Right("daisy")
  #   Right(Left("daisy")).join_left  #=> Right(Left("daisy"))
  #
  # @see https://github.com/scala/scala/blob/2.12.x/src/library/scala/util/Either.scala
  #
  module Either
    include Dry::Equalizer(:value)
    include Functional

    def left_class
      Left
    end

    def right_class
      Right
    end

    def initialize(value)
      @value = value
    end

    attr_reader :value
    protected :value

    module Mixin
      # @param [any]
      # @return [Left]
      def Left(value)
        Left.new(value)
      end

      # @param [any]
      # @return [Right]
      def Right(value)
        Right.new(value)
      end
    end
  end
end
