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
  #     Fear.right(Integer(in))
  #   rescue ArgumentError
  #     Fear.left(in)
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
  #       Fear.right(42).get_or_else { 24/2 }         #=> 42
  #       Fear.left('undefined').get_or_else { 24/2 } #=> 12
  #   @overload get_or_else(default)
  #     @return [any]
  #     @example
  #       Fear.right(42).get_or_else(12)         #=> 42
  #       Fear.left('undefined').get_or_else(12) #=> 12
  #
  # @!method or_else(&alternative)
  #   Returns this +Right+ or the given alternative if this is a +Left+.
  #   @return [Either]
  #   @example
  #     Fear.right(42).or_else { Fear.right(21) }           #=> Fear.right(42)
  #     Fear.left('unknown').or_else { Fear.right(21) }     #=> Fear.right(21)
  #     Fear.left('unknown').or_else { Fear.left('empty') } #=> Fear.left('empty')
  #
  # @!method include?(other_value)
  #   Returns +true+ if +Right+ has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Fear.right(17).include?(17)         #=> true
  #     Fear.right(17).include?(7)          #=> false
  #     Fear.left('undefined').include?(17) #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Right+.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Option] itself
  #   @example
  #     Fear.right(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     Fear.left('undefined').each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Right+ or
  #   returns this if this is a +Left+.
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Fear.right(42).map { |v| v/2 }          #=> Fear.right(21)
  #     Fear.left('undefined').map { |v| v/2 }  #=> Fear.left('undefined')
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Right+
  #   or returns this if this is a +Left+.
  #   @yieldparam [any] value
  #   @yieldreturn [Option]
  #   @return [Option]
  #   @example
  #     Fear.right(42).flat_map { |v| Fear.right(v/2) }         #=> Fear.right(21)
  #     Fear.left('undefined').flat_map { |v| Fear.right(v/2) } #=> Fear.left('undefined')
  #
  # @!method to_option
  #   Returns an +Some+ containing the +Right+ value or a +None+ if
  #   this is a +Left+.
  #   @return [Option]
  #   @example
  #     Fear.right(42).to_option          #=> Fear.some(21)
  #     Fear.left('undefined').to_option  #=> Fear.none()
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +Left+ or returns the result of the
  #   application of the given predicate to the +Right+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Fear.right(12).any?( |v| v > 10)         #=> true
  #     Fear.right(7).any?( |v| v > 10)          #=> false
  #     Fear.left('undefined').any?( |v| v > 10) #=> false
  #
  # -----
  #
  # @!method right?
  #   Returns +true+ if this is a +Right+, +false+ otherwise.
  #   @note this method is also aliased as +#success?+
  #   @return [Boolean]
  #   @example
  #     Fear.right(42).right?   #=> true
  #     Fear.left('err').right? #=> false
  #
  # @!method left?
  #   Returns +true+ if this is a +Left+, +false+ otherwise.
  #   @note this method is also aliased as +#failure?+
  #   @return [Boolean]
  #   @example
  #     Fear.right(42).left?   #=> false
  #     Fear.left('err').left? #=> true
  #
  # @!method select_or_else(default, &predicate)
  #   Returns +Left+ of the default if the given predicate
  #   does not hold for the right value, otherwise, returns +Right+.
  #   @param default [Object, Proc]
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Fear.right(12).select_or_else(-1, &:even?)       #=> Fear.right(12)
  #     Fear.right(7).select_or_else(-1, &:even?)        #=> Fear.left(-1)
  #     Fear.left(12).select_or_else(-1, &:even?)        #=> Fear.left(12)
  #     Fear.left(12).select_or_else(-> { -1 }, &:even?) #=> Fear.left(12)
  #
  # @!method select(&predicate)
  #   Returns +Left+ of value if the given predicate
  #   does not hold for the right value, otherwise, returns +Right+.
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Fear.right(12).select(&:even?) #=> Fear.right(12)
  #     Fear.right(7).select(&:even?)  #=> Fear.left(7)
  #     Fear.left(12).select(&:even?)  #=> Fear.left(12)
  #     Fear.left(7).select(&:even?)   #=> Fear.left(7)
  #
  # @!method reject(&predicate)
  #   Returns +Left+ of value if the given predicate holds for the
  #   right value, otherwise, returns +Right+.
  #   @yieldparam value [Object]
  #   @yieldreturn [Boolean]
  #   @return [Either]
  #   @example
  #     Fear.right(12).reject(&:even?) #=> Fear.left(12)
  #     Fear.right(7).reject(&:even?)  #=> Fear.right(7)
  #     Fear.left(12).reject(&:even?)  #=> Fear.left(12)
  #     Fear.left(7).reject(&:even?)   #=> Fear.left(7)
  #
  # @!method swap
  #   If this is a +Left+, then return the left value in +Right+ or vice versa.
  #   @return [Either]
  #   @example
  #     Fear.left('left').swap   #=> Fear.right('left')
  #     Fear.right('right').swap #=> Fear.left('left')
  #
  # @!method reduce(&matcher)
  #   Applies +reduce_left+ if this is a +Left+ or +reduce_right+ if
  #   this is a +Right+.
  #   @yieldparam [Fear::Matcher]
  #   @return [any] the results of applying the Proc
  #   @example
  #     result = possibly_failing_operation()
  #     log(
  #       result.reduce do |m|
  #         m.left { |error| "Operation failed with #{error}" }
  #         m.right { |value| "Operation produced value: #{value}" }
  #       )
  #     )
  #
  # @!method join_right
  #   Joins an +Either+ through +Right+. This method requires
  #   that the right side of this +Either+ is itself an
  #   +Either+ type.
  #   @note This method, and +join_left+, are analogous to +Option#flatten+
  #   @return [Either]
  #   @raise [TypeError] if it does not contain +Either+.
  #   @example
  #     Fear.right(Fear.right(12)).join_right      #=> Fear.right(12)
  #     Fear.right(Fear.left("flower")).join_right #=> Fear.left("flower")
  #     Fear.left("flower").join_right             #=> Fear.left("flower")
  #     Fear.left(Fear.right("flower")).join_right #=> Fear.left(Fear.right("flower"))
  #
  # @!method join_right
  #   Joins an +Either+ through +Left+. This method requires
  #   that the left side of this +Either+ is itself an
  #   +Either+ type.
  #   @note This method, and +join_right+, are analogous to +Option#flatten+
  #   @return [Either]
  #   @raise [TypeError] if it does not contain +Either+.
  #   @example
  #     Fear.left(Fear.right("flower")).join_left   #=> Fear.right("flower")
  #     Fear.left(Fear.left(12)).join_left          #=> Fear.left(12)
  #     Fear.right("daisy").join_left               #=> Fear.right("daisy")
  #     Fear.right(Fear.left("daisy")).join_left    #=> Fear.right(Fear.left("daisy"))
  #
  # @!method match(&matcher)
  #   Pattern match against this +Either+
  #   @yield matcher [Fear::EitherPatternMatch]
  #   @example
  #     either.match do |m|
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

    # @param other [Any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && value == other.value
    end

    # @return [String]
    def inspect
      "#<#{self.class} value=#{value.inspect}>"
    end

    # @return [String]
    alias to_s inspect

    # @yieldparam [Fear::PatternMatch]
    # @return [any]
    def reduce(&block)
      match(&block)
    end

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
      #   matcher.call(Fear.right(42))
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
      # @param value [any]
      # @return [Fear::Left]
      # @example
      #   Left(42) #=> #<Fear::Left value=42>
      #
      def Left(value)
        Fear.left(value)
      end

      # @param value [any]
      # @return [Fear::Right]
      # @example
      #   Right(42) #=> #<Fear::Right value=42>
      #
      def Right(value)
        Fear.right(value)
      end
    end
  end
end
