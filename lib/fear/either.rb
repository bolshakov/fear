module Fear
  # Represents a value of one of two possible types (a disjoint union.)
  # An instance of +Either+ is either an instance of +Left+ or +Right+.
  #
  # A common use of +Either+ is as an alternative to +Option+ for dealing
  # with possible missing values.  In this usage, +None+ is replaced
  # with a +Left+ which can contain useful information.
  # +Right+ takes the place of +Some+. Convention dictates
  # that +Left+ is used for failure and +Right+ is used for Right.
  #
  # For example, you could use +Either<String, Fixnum>+ to select_or_else whether a
  # received input is a +String+ or an +Fixnum+.
  #
  # @example
  #   in = Readline.readline('Type Either a string or an Int: ', true)
  #   result = begin
  #     Right(Integer(in))
  #   rescue ArgumentError
  #     Left(in)
  #   end
  #
  #   result.match do |m|
  #     m.right do |x|
  #       "You passed me the Int: #{x}, which I will increment. #{x} + 1 = #{x+1}"
  #     end
  #
  #     m.left do |x|
  #       "You passed me the String: #{x}"
  #     end
  #   end
  #
  # Either is right-biased, which means that +Right+ is assumed to be the default case to
  # operate on. If it is +Left+, operations like +#map+, +#flat_map+, ... return the +Left+ value
  # unchanged:
  #
  # @!method get_or_else(*args)
  #   Returns the value from this +Right+ or evaluates the given
  #   default argument if this is a +Left+.
  #   @overload get_or_else(&default)
  #     @yieldreturn [any]
  #     @return [any]
  #     @example
  #       Right(42).get_or_else { 24/2 }         #=> 42
  #       Left('undefined').get_or_else { 24/2 } #=> 12
  #   @overload get_or_else(default)
  #     @return [any]
  #     @example
  #       Right(42).get_or_else(12)         #=> 42
  #       Left('undefined').get_or_else(12) #=> 12
  #
  # @!method or_else(&alternative)
  #   Returns this +Right+ or the given alternative if this is a +Left+.
  #   @return [Either]
  #   @example
  #     Right(42).or_else { Right(21) }           #=> Right(42)
  #     Left('unknown').or_else { Right(21) }     #=> Right(21)
  #     Left('unknown').or_else { Left('empty') } #=> Left('empty')
  #
  # @!method include?(other_value)
  #   Returns +true+ if +Right+ has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Right(17).include?(17)         #=> true
  #     Right(17).include?(7)          #=> false
  #     Left('undefined').include?(17) #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Right+.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Option] itself
  #   @example
  #     Right(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     Left('undefined').each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Right+ or
  #   returns this if this is a +Left+.
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Right(42).map { |v| v/2 }          #=> Right(21)
  #     Left('undefined').map { |v| v/2 }  #=> Left('undefined')
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Right+
  #   or returns this if this is a +Left+.
  #   @yieldparam [any] value
  #   @yieldreturn [Option]
  #   @return [Option]
  #   @example
  #     Right(42).flat_map { |v| Right(v/2) }         #=> Right(21)
  #     Left('undefined').flat_map { |v| Right(v/2) } #=> Left('undefined')
  #
  # @!method to_a
  #   Returns an +Array+ containing the +Right+ value or an
  #   empty +Array+ if this is a +Left+.
  #   @return [Array]
  #   @example
  #     Right(42).to_a          #=> [21]
  #     Left('undefined').to_a  #=> []
  #
  # @!method to_option
  #   Returns an +Some+ containing the +Right+ value or a +None+ if
  #   this is a +Left+.
  #   @return [Option]
  #   @example
  #     Right(42).to_option          #=> Some(21)
  #     Left('undefined').to_option  #=> None()
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +Left+ or returns the result of the
  #   application of the given predicate to the +Right+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Right(12).any?( |v| v > 10)         #=> true
  #     Right(7).any?( |v| v > 10)          #=> false
  #     Left('undefined').any?( |v| v > 10) #=> false
  #
  # -----
  #
  # @!method right?
  #   Returns +true+ if this is a +Right+, +false+ otherwise.
  #   @note this method is also aliased as +#success?+
  #   @return [Boolean]
  #   @example
  #     Right(42).right?   #=> true
  #     Left('err').right? #=> false
  #
  # @!method left?
  #   Returns +true+ if this is a +Left+, +false+ otherwise.
  #   @note this method is also aliased as +#failure?+
  #   @return [Boolean]
  #   @example
  #     Right(42).left?   #=> false
  #     Left('err').left? #=> true
  #
  # @!method select_or_else(default, &predicate)
  #   Returns +Left+ of the default if the given predicate
  #   does not hold for the right value, otherwise, returns +Right+.
  #   @param default [Object, Proc]
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Right(12).select_or_else(-1, &:even?)       #=> Right(12)
  #     Right(7).select_or_else(-1, &:even?)        #=> Left(-1)
  #     Left(12).select_or_else(-1, &:even?)        #=> Left(12)
  #     Left(12).select_or_else(-> { -1 }, &:even?) #=> Left(12)
  #
  # @!method select(&predicate)
  #   Returns +Left+ of value if the given predicate
  #   does not hold for the right value, otherwise, returns +Right+.
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Right(12).select(&:even?) #=> Right(12)
  #     Right(7).select(&:even?)  #=> Left(7)
  #     Left(12).select(&:even?)  #=> Left(12)
  #     Left(7).select(&:even?)   #=> Left(7)
  #
  # @!method reject(&predicate)
  #   Returns +Left+ of value if the given predicate holds for the
  #   right value, otherwise, returns +Right+.
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Right(12).reject(&:even?) #=> Left(12)
  #     Right(7).reject(&:even?)  #=> Right(7)
  #     Left(12).reject(&:even?)  #=> Left(12)
  #     Left(7).reject(&:even?)   #=> Left(7)
  #
  # @!method swap
  #   If this is a +Left+, then return the left value in +Right+ or vice versa.
  #   @return [Either]
  #   @example
  #     Left('left').swap   #=> Right('left')
  #     Right('right').swap #=> Light('left')
  #
  # @!method reduce(reduce_left, reduce_right)
  #   Applies +reduce_left+ if this is a +Left+ or +reduce_right+ if
  #   this is a +Right+.
  #   @param reduce_left [Proc] the Proc to apply if this is a +Left+
  #   @param reduce_right [Proc] the Proc to apply if this is a +Right+
  #   @return [any] the results of applying the Proc
  #   @example
  #     result = possibly_failing_operation()
  #     log(
  #       result.reduce(
  #         ->(ex) { "Operation failed with #{ex}" },
  #         ->(v) { "Operation produced value: #{v}" },
  #       )
  #     )
  #
  #
  # @!method join_right
  #   Joins an +Either+ through +Right+. This method requires
  #   that the right side of this +Either+ is itself an
  #   +Either+ type.
  #   @note This method, and +join_left+, are analogous to +Option#flatten+
  #   @return [Either]
  #   @raise [TypeError] if it does not contain +Either+.
  #   @example
  #     Right(Right(12)).join_right      #=> Right(12)
  #     Right(Left("flower")).join_right #=> Left("flower")
  #     Left("flower").join_right        #=> Left("flower")
  #     Left(Right("flower")).join_right #=> Left(Right("flower"))
  #
  # @!method join_right
  #   Joins an +Either+ through +Left+. This method requires
  #   that the left side of this +Either+ is itself an
  #   +Either+ type.
  #   @note This method, and +join_right+, are analogous to +Option#flatten+
  #   @return [Either]
  #   @raise [TypeError] if it does not contain +Either+.
  #   @example
  #     Left(Right("flower")).join_left #=> Right("flower")
  #     Left(Left(12)).join_left        #=> Left(12)
  #     Right("daisy").join_left        #=> Right("daisy")
  #     Right(Left("daisy")).join_left  #=> Right(Left("daisy"))
  #
  # @!method match(&matcher)
  #   Pattern match against this +Either+
  #   @yield matcher [Fear::EitherPatternMatch]
  #   @example
  #     Either(val).match do |m|
  #       m.right(Integer) do |x|
  #        x * 2
  #       end
  #
  #       m.right(String) do |x|
  #         x.to_i * 2
  #       end
  #
  #       m.left { |x| x }
  #       m.else { 'something unexpected' }
  #     end
  #
  # @see https://github.com/scala/scala/blob/2.12.x/src/library/scala/util/Either.scala
  #
  module Either
    include Dry::Equalizer(:value)

    # @private
    def left_class
      Left
    end

    # @private
    def right_class
      Right
    end

    def initialize(value)
      @value = value
    end

    attr_reader :value
    protected :value

    class << self
      # Build pattern matcher to be used later, despite off
      # +Either#match+ method, id doesn't apply matcher immanently,
      # but build it instead. Unusually in sake of efficiency it's better
      # to statically build matcher and reuse it later.
      #
      # @example
      #   matcher =
      #     Either.matcher do |m|
      #       m.right(Integer, ->(x) { x > 2 }) { |x| x * 2 }
      #       m.right(String) { |x| x.to_i * 2 }
      #       m.left(String) { :err }
      #       m.else { 'error '}
      #     end
      #   matcher.call(Some(42))
      #
      # @yieldparam [Fear::EitherPatternMatch]
      # @return [Fear::PartialFunction]
      def matcher(&matcher)
        EitherPatternMatch.new(&matcher)
      end
    end

    # Include this mixin to access convenient factory methods.
    # @example
    #   include Fear::Either::Mixin
    #
    #   Right('flower') #=> #<Fear::Right value='flower'>
    #   Left('beaf')    #=> #<Fear::Legt value='beaf'>
    #
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
