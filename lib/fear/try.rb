# frozen_string_literal: true

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
  #   dividend = Fear.try { Integer(params[:dividend]) }
  #   divisor = Fear.try { Integer(params[:divisor]) }
  #   problem = dividend.flat_map { |x| divisor.map { |y| x / y } }
  #
  #   problem.match |m|
  #     m.success do |result|
  #       puts "Result of #{dividend.get} / #{divisor.get} is: #{result}"
  #     end
  #
  #     m.failure(ZeroDivisionError) do
  #       puts "Division by zero is not allowed"
  #     end
  #
  #     m.failure do |exception|
  #       puts "You entered something wrong. Try again"
  #       puts "Info from the exception: #{exception.message}"
  #     end
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
  #       Fear.success(42).get_or_else { 24/2 }                #=> 42
  #       Fear.failure(ArgumentError.new).get_or_else { 24/2 } #=> 12
  #   @overload get_or_else(default)
  #     @return [any]
  #     @example
  #       Fear.success(42).get_or_else(12)                #=> 42
  #       Fear.failure(ArgumentError.new).get_or_else(12) #=> 12
  #
  # @!method include?(other_value)
  #   Returns +true+ if it has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Fear.success(17).include?(17)                #=> true
  #     Fear.success(17).include?(7)                 #=> false
  #     Fear.failure(ArgumentError.new).include?(17) #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Success+.
  #   @note if block raise an error, then this method may raise an exception.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Try] itself
  #   @example
  #     Fear.success(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     Fear.failure(ArgumentError.new).each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Success+ or
  #   returns this if this is a +Failure+.
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Fear.success(42).map { |v| v/2 }                 #=> Fear.success(21)
  #     Fear.failure(ArgumentError.new).map { |v| v/2 }  #=> Fear.failure(ArgumentError.new)
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Success+
  #   or returns this if this is a +Failure+.
  #   @yieldparam [any] value
  #   @yieldreturn [Try]
  #   @return [Try]
  #   @example
  #     Fear.success(42).flat_map { |v| Fear.success(v/2) }
  #       #=> Fear.success(21)
  #     Fear.failure(ArgumentError.new).flat_map { |v| Fear.success(v/2) }
  #       #=> Fear.failure(ArgumentError.new)
  #
  # @!method to_option
  #   Returns an +Some+ containing the +Success+ value or a +None+ if
  #   this is a +Failure+.
  #   @return [Option]
  #   @example
  #     Fear.success(42).to_option                 #=> Fear.some(42)
  #     Fear.failure(ArgumentError.new).to_option  #=> Fear.none()
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +Failure+ or returns the result of the
  #   application of the given predicate to the +Success+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Fear.success(12).any?( |v| v > 10)                #=> true
  #     Fear.success(7).any?( |v| v > 10)                 #=> false
  #     Fear.failure(ArgumentError.new).any?( |v| v > 10) #=> false
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
  #     Fear.success(42).get                 #=> 42
  #     Fear.failure(ArgumentError.new).get  #=> ArgumentError: ArgumentError
  #
  # @!method or_else(&alternative)
  #   Returns this +Try+ if it's a +Success+ or the given alternative if this is a +Failure+.
  #   @return [Try]
  #   @example
  #     Fear.success(42).or_else { Fear.success(-1) }                 #=> Fear.success(42)
  #     Fear.failure(ArgumentError.new).or_else { Fear.success(-1) }  #=> Fear.success(-1)
  #     Fear.failure(ArgumentError.new).or_else { Fear.try { 1/0 } }
  #       #=> Fear.failure(ZeroDivisionError.new('divided by 0'))
  #
  # @!method flatten
  #   Transforms a nested +Try+, ie, a +Success+ of +Success+,
  #   into an un-nested +Try+, ie, a +Success+.
  #   @return [Try]
  #   @example
  #     Fear.success(42).flatten                         #=> Fear.success(42)
  #     Fear.success(Fear.success(42)).flatten                #=> Fear.success(42)
  #     Fear.success(Fear.failure(ArgumentError.new)).flatten #=> Fear.failure(ArgumentError.new)
  #     Fear.failure(ArgumentError.new).flatten { -1 }   #=> Fear.failure(ArgumentError.new)
  #
  # @!method select(&predicate)
  #   Converts this to a +Failure+ if the predicate is not satisfied.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Try]
  #   @example
  #     Fear.success(42).select { |v| v > 40 }
  #       #=> Fear.success(42)
  #     Fear.success(42).select { |v| v < 40 }
  #       #=> Fear.failure(Fear::NoSuchElementError.new("Predicate does not hold for 42"))
  #     Fear.failure(ArgumentError.new).select { |v| v < 40 }
  #       #=> Fear.failure(ArgumentError.new)
  #
  # @!method recover_with(&block)
  #   Applies the given block to exception. This is like +flat_map+
  #   for the exception.
  #   @yieldparam [Fear::PatternMatch] matcher
  #   @yieldreturn [Fear::Try]
  #   @return [Fear::Try]
  #   @example
  #     Fear.success(42).recover_with do |m|
  #       m.case(ZeroDivisionError) { Fear.success(0) }
  #     end #=> Fear.success(42)
  #
  #     Fear.failure(ArgumentError.new).recover_with do |m|
  #       m.case(ZeroDivisionError) { Fear.success(0) }
  #       m.case(ArgumentError) { |error| Fear.success(error.class.name) }
  #     end #=> Fear.success('ArgumentError')
  #
  #     # If the block raises error, this new error returned as an result
  #
  #     Fear.failure(ArgumentError.new).recover_with do |m|
  #       raise
  #     end #=> Fear.failure(RuntimeError)
  #
  # @!method recover(&block)
  #   Applies the given block to exception. This is like +map+ for the exception.
  #   @yieldparam [Fear::PatternMatch] matcher
  #   @yieldreturn [any]
  #   @return [Fear::Try]
  #   @example #recover
  #     Fear.success(42).recover do |m|
  #       m.case(&:message)
  #     end #=> Fear.success(42)
  #
  #     Fear.failure(ArgumentError.new).recover do |m|
  #       m.case(ZeroDivisionError) { 0 }
  #       m.case(&:message)
  #     end #=> Fear.success('ArgumentError')
  #
  #     # If the block raises error, this new error returned as an result
  #
  #     Fear.failure(ArgumentError.new).recover do |m|
  #       raise
  #     end #=> Fear.failure(RuntimeError)
  #
  # @!method to_either
  #   Returns +Left+ with exception if this is a +Failure+, otherwise
  #   returns +Right+ with +Success+ value.
  #   @return [Right<any>, Left<StandardError>]
  #   @example
  #     Fear.success(42).to_either                #=> Fear.right(42)
  #     Fear.failure(ArgumentError.new).to_either #=> Fear.left(ArgumentError.new)
  #
  # @!method match(&matcher)
  #   Pattern match against this +Try+
  #   @yield matcher [Fear::Try::PatternMatch]
  #   @example
  #     Fear.try { ... }.match do |m|
  #       m.success(Integer) do |x|
  #        x * 2
  #       end
  #
  #       m.success(String) do |x|
  #         x.to_i * 2
  #       end
  #
  #       m.failure(ZeroDivisionError) { 'not allowed to divide by 0' }
  #       m.else { 'something unexpected' }
  #     end
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

    class << self
      # Build pattern matcher to be used later, despite off
      # +Try#match+ method, id doesn't apply matcher immanently,
      # but build it instead. Unusually in sake of efficiency it's better
      # to statically build matcher and reuse it later.
      #
      # @example
      #   matcher =
      #     Try.matcher do |m|
      #       m.success(Integer, ->(x) { x > 2 }) { |x| x * 2 }
      #       m.success(String) { |x| x.to_i * 2 }
      #       m.failure(ActiveRecord::RecordNotFound) { :err }
      #       m.else { 'error '}
      #     end
      #   matcher.call(try)
      #
      # @yieldparam [Fear::Try::PatternMatch]
      # @return [Fear::PartialFunction]
      def matcher(&matcher)
        Try::PatternMatch.new(&matcher)
      end
    end

    # Include this mixin to access convenient factory methods.
    # @example
    #   include Fear::Try::Mixin
    #
    #   Fear.try { 4/2 } #=> #<Fear::Success value=2>
    #   Fear.try { 4/0 } #=> #<Fear::Failure exception=#<ZeroDivisionError: divided by 0>>
    #   Fear.success(2)  #=> #<Fear::Success value=2>
    #
    module Mixin
      # Constructs a +Try+ using the block. This
      # method ensures any non-fatal exception is caught and a
      # +Failure+ object is returned.
      # @return [Try]
      #
      def Try(&block)
        Fear.try(&block)
      end

      # @param exception [StandardError]
      # @return [Failure]
      #
      def Failure(exception)
        Fear.failure(exception)
      end

      # @param value [any]
      # @return [Success]
      #
      def Success(value)
        Fear.success(value)
      end
    end
  end
end

require "fear/try/pattern_match"
require "fear/success"
require "fear/failure"
