module Fear
  # The +Try+ represents a computation that may either result
  # in an exception, or return a successfully computed value. Instances of +Try+,
  # are either an instance of +Success+ or +Failure+.
  #
  # For example, +Try+ can be used to perform division on a
  # user-defined input, without the need to do explicit
  # exception-handling in all of the places that an exception
  # might occur.
  #
  # @example
  #   include Fear::Try::Mixin
  #
  #   dividend = Try { Integer(params[:dividend]) }
  #   divisor = Try { Integer(params[:divisor]) }
  #   problem = dividend.flat_map { |x| divisor.map { |y| x / y }
  #
  #   if problem.success?
  #     puts "Result of #{dividend.get} / #{divisor.get} is: #{problem.get}"
  #   else
  #     puts "You must've divided by zero or entered something wrong. Try again"
  #     puts "Info from the exception: #{problem.exception.message}"
  #   end
  #
  # An important property of +Try+ shown in the above example is its
  # ability to _pipeline_, or chain, operations, catching exceptions
  # along the way. The +flat_map+ and +map+ combinators in the above
  # example each essentially pass off either their successfully completed
  # value, wrapped in the +Success+ type for it to be further operated
  # upon by the next combinator in the chain, or the exception wrapped
  # in the +Failure+ type usually to be simply passed on down the chain.
  # Combinators such as +recover_with+ and +recover+ are designed to provide some
  # type of default behavior in the case of failure.
  #
  # @note only non-fatal exceptions are caught by the combinators on +Try+.
  #   Serious system errors, on the other hand, will be thrown.
  #
  # @note all +Try+ combinators will catch exceptions and return failure unless
  #   otherwise specified in the documentation.
  #
  # @!method get_or_else(*args)
  #   Returns the value from this +Success+ or evaluates the given
  #   default argument if this is a +Failure+.
  #   @overload get_or_else(&default)
  #     @yieldreturn [any]
  #     @return [any]
  #     @example
  #       Success(42).get_or_else { 24/2 }                #=> 42
  #       Failure(ArgumentError.new).get_or_else { 24/2 } #=> 12
  #   @overload get_or_else(default)
  #     @return [any]
  #     @example
  #       Success(42).get_or_else(12)                #=> 42
  #       Failure(ArgumentError.new).get_or_else(12) #=> 12
  #
  # @!method include?(other_value)
  #   Returns +true+ if it has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Success(17).include?(17)                #=> true
  #     Success(17).include?(7)                 #=> false
  #     Failure(ArgumentError.new).include?(17) #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Success+.
  #   @note if block raise an error, then this method may raise an exception.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Try] itself
  #   @example
  #     Success(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     Failure(ArgumentError.new).each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Success+ or
  #   returns this if this is a +Failure+.
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Success(42).map { |v| v/2 }                 #=> Success(21)
  #     Failure(ArgumentError.new).map { |v| v/2 }  #=> Failure(ArgumentError.new)
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Success+
  #   or returns this if this is a +Failure+.
  #   @yieldparam [any] value
  #   @yieldreturn [Try]
  #   @return [Try]
  #   @example
  #     Success(42).flat_map { |v| Success(v/2) }
  #       #=> Success(21)
  #     Failure(ArgumentError.new).flat_map { |v| Success(v/2) }
  #       #=> Failure(ArgumentError.new)
  #
  # @!method to_a
  #   Returns an +Array+ containing the +Success+ value or an
  #   empty +Array+ if this is a +Failure+.
  #   @return [Array]
  #   @example
  #     Success(42).to_a                 #=> [21]
  #     Failure(ArgumentError.new).to_a  #=> []
  #
  # @!method to_option
  #   Returns an +Some+ containing the +Success+ value or a +None+ if
  #   this is a +Failure+.
  #   @return [Option]
  #   @example
  #     Success(42).to_option                 #=> Some(21)
  #     Failure(ArgumentError.new).to_option  #=> None()
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +Failure+ or returns the result of the
  #   application of the given predicate to the +Success+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Success(12).any?( |v| v > 10)                #=> true
  #     Success(7).any?( |v| v > 10)                 #=> false
  #     Failure(ArgumentError.new).any?( |v| v > 10) #=> false
  #
  # ---
  #
  # @!method success?
  #   Returns +true+ if it is a +Success+, +false+ otherwise.
  #   @return [Boolean]
  #
  # @!method failure?
  #   Returns +true+ if it is a +Failure+, +false+ otherwise.
  #   @return [Boolean]
  #
  # @!method get
  #   Returns the value from this +Success+ or raise the exception
  #   if this is a +Failure+.
  #   @return [any]
  #   @example
  #     Success(42).get                 #=> 42
  #     Failure(ArgumentError.new).get  #=> ArgumentError: ArgumentError
  #
  # @!method or_else(&default)
  #   Returns this +Try+ if it's a +Success+ or the given default
  #   argument if this is a +Failure+.
  #   @return [Try]
  #   @example
  #     Success(42).or_else { -1 }                 #=> Success(42)
  #     Failure(ArgumentError.new).or_else { -1 }  #=> Success(-1)
  #     Failure(ArgumentError.new).or_else { 1/0 } #=> Failure(ZeroDivisionError.new('divided by 0'))
  #
  # @!method flatten
  #   Transforms a nested +Try+, ie, a +Success+ of +Success+,
  #   into an un-nested +Try+, ie, a +Success+.
  #   @return [Try]
  #   @example
  #     Success(42).flatten                         #=> Success(42)
  #     Success(Success(42)).flatten                #=> Success(42)
  #     Success(Failure(ArgumentError.new)).flatten #=> Failure(ArgumentError.new)
  #     Failure(ArgumentError.new).flatten { -1 }   #=> Failure(ArgumentError.new)
  #
  # @!method select(&predicate)
  #   Converts this to a +Failure+ if the predicate is not satisfied.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Try]
  #   @example
  #     Success(42).select { |v| v > 40 }
  #       #=> Success(21)
  #     Success(42).select { |v| v < 40 }
  #       #=> Failure(Fear::NoSuchElementError.new("Predicate does not hold for 42"))
  #     Failure(ArgumentError.new).select { |v| v < 40 }
  #       #=> Failure(ArgumentError.new)
  #
  # @!method recover_with(&block)
  #   Applies the given block to exception. This is like +flat_map+
  #   for the exception.
  #   @yieldparam [Exception] exception
  #   @yieldreturn [Try]
  #   @return [Try]
  #   @example
  #     Success(42).recover_with { |e| Success(e.massage) }
  #       #=> Success(42)
  #     Failure(ArgumentError.new).recover_with { |e| Success(e.massage) }
  #       #=> Success('ArgumentError')
  #     Failure(ArgumentError.new).recover_with { |e| fail }
  #       #=> Failure(RuntimeError)
  #
  # @!method recover(&block)
  #   Applies the given block to exception. This is like +map+ for the exception.
  #   @yieldparam [Exception] exception
  #   @yieldreturn [any]
  #   @return [Try]
  #   @example #recover
  #     Success(42).recover { |e| e.massage }
  #       #=> Success(42)
  #     Failure(ArgumentError.new).recover { |e| e.massage }
  #       #=> Success('ArgumentError')
  #     Failure(ArgumentError.new).recover { |e| fail }
  #       #=> Failure(RuntimeError)
  #
  # @!method to_either
  #   Returns +Left+ with exception if this is a +Failure+, otherwise
  #   returns +Right+ with +Success+ value.
  #   @return [Right<any>, Left<StandardError>]
  #   @example
  #     Success(42).to_either                #=> Right(42)
  #     Failure(ArgumentError.new).to_either #=> Left(ArgumentError.new)
  #
  # @author based on Twitter's original implementation.
  # @see https://github.com/scala/scala/blob/2.11.x/src/library/scala/util/Try.scala
  #
  module Try
    # @private
    def left_class
      Failure
    end

    # @private
    def right_class
      Success
    end

    # Include this mixin to access convenient factory methods.
    # @example
    #   include Fear::Try::Mixin
    #
    #   Try { 4/2 } #=> #<Fear::Success value=2>
    #   Try { 4/0 } #=> #<Fear::Failure value=#<ZeroDivisionError: divided by 0>>
    #   Success(2)  #=> #<Fear::Success value=2>
    #
    module Mixin
      # Constructs a +Try+ using the block. This
      # method will ensure any non-fatal exception )is caught and a
      # +Failure+ object is returned.
      # @return [Try]
      #
      def Try
        Success.new(yield)
      rescue => error
        Failure.new(error)
      end

      # @param exception [StandardError]
      # @return [Failure]
      #
      def Failure(exception)
        Failure.new(exception)
      end

      # @param value [any]
      # @return [Success]
      #
      def Success(value)
        Success.new(value)
      end
    end
  end
end
