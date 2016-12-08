module Functional
  # The `Try` represents a computation that may either result
  # in an exception, or return a successfully computed value.
  #
  # Instances of `Try`, are either an instance of `Success` or
  # `Failure`.
  #
  # For example, `Try` can be used to perform division on a
  # user-defined input, without the need to do explicit
  # exception-handling in all of the places that an exception
  # might occur.
  #
  # @example
  #   dividend = Try { params[:dividend].to_i }
  #   divisor = Try { params[:divisor].to_i }
  #   problem = dividend.flat_map { |x| divisor.map { |y| x / y }
  #
  #   if problem.success?
  #     puts "Result of #{dividend.get} / #{divisor.get} is: #{problem.get}"
  #   else
  #     puts "You must've divided by zero or entered something wrong. Try again"
  #     puts "Info from the exception: #{problem.exception.message}"
  #   end
  #
  # An important property of `Try` shown in the above example is its
  # ability to `pipeline`, or chain, operations, catching exceptions
  # along the way. The `flat_map` and `map` combinators in the above
  # example each essentially pass off either their successfully completed
  # value, wrapped in the `Success` type for it to be further operated
  # upon by the next combinator in the chain, or the exception wrapped
  # in the `Failure` type usually to be simply passed on down the chain.
  # Combinators such as `rescue` and `recover` are designed to provide some
  # type of default behavior in the case of failure.
  #
  # @note only non-fatal exceptions are caught by the combinators on `Try`.
  # Serious system errors, on the other hand, will be thrown.
  #
  # @note all `Try` combinators will catch exceptions and return failure
  # unless otherwise specified in the documentation.
  #
  # @example #or_else
  #   Success(42).or_else { -1 }                 #=> Success(42)
  #   Failure(ArgumentError.new).or_else { -1 }  #=> Success(-1)
  #   Failure(ArgumentError.new).or_else { 1/0 } #=> Failure(ZeroDivisionError.new('divided by 0'))
  #
  # @example #flatten
  #   Success(42).flatten                         #=> Success(42)
  #   Success(Success(42)).flatten                #=> Success(42)
  #   Success(Failure(ArgumentError.new)).flatten #=> Failure(ArgumentError.new)
  #   Failure(ArgumentError.new).flatten { -1 }   #=> Failure(ArgumentError.new)
  #
  # @example #map
  #   Success(42).map { |v| v/2 }                 #=> Success(21)
  #   Failure(ArgumentError.new).map { |v| v/2 }  #=> Failure(ArgumentError.new)
  #
  # @example #detect
  #   Success(42).detect { |v| v > 40 }
  #     #=> Success(21)
  #   Success(42).detect { |v| v < 40 }
  #     #=> Failure(NoSuchElementError.new("Predicate does not hold for 42"))
  #   Failure(ArgumentError.new).detect { |v| v < 40 }
  #     #=> Failure(ArgumentError.new)
  #
  # @example #recover_with
  #   Success(42).recover_with { |e| Success(e.massage) }
  #     #=> Success(42)
  #   Failure(ArgumentError.new).recover_with { |e| Success(e.massage) }
  #     #=> Success('ArgumentError')
  #   Failure(ArgumentError.new).recover_with { |e| fail }
  #     #=> Failure(RuntimeError)
  #
  # @example #recover
  #   Success(42).recover { |e| e.massage }
  #     #=> Success(42)
  #   Failure(ArgumentError.new).recover { |e| e.massage }
  #     #=> Success('ArgumentError')
  #   Failure(ArgumentError.new).recover { |e| fail }
  #     #=> Failure(RuntimeError)
  #
  # @author based on Twitter's original implementation.
  # @see https://github.com/scala/scala/blob/2.11.x/src/library/scala/util/Try.scala
  #
  module Try
    def left_class
      Failure
    end

    def right_class
      Success
    end

    # @return [true, false] `true` if the `Try` is a `Failure`,
    #   `false` otherwise.
    #
    def failure?
      !success?
    end
  end
end
