# Fear
[![Gem Version](https://badge.fury.io/rb/fear.svg)](https://badge.fury.io/rb/fear)
![Specs](https://github.com/bolshakov/fear/workflows/Spec/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/01030620c59e9f40961b/maintainability)](https://codeclimate.com/github/bolshakov/fear/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/bolshakov/fear/badge.svg?branch=master)](https://coveralls.io/github/bolshakov/fear?branch=master)

This gem provides `Option`, `Either`, and `Try` monads implemented an idiomatic way. 
 It is highly inspired by scala's implementation. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fear'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fear

## Usage

* [Option](#option-api-documentation) 
* [Try](#try-api-documentation)
* [Either](#either-api-documentation)
* [Future](#future-api-documentation)
* [For composition](#for-composition-api-documentation)
* [Pattern Matching](#pattern-matching-api-documentation)

### Option ([API Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/Option))

Represents optional (nullable) values. Instances of `Option` are either an instance of 
`Some` or the object `None`.

The most idiomatic way to use an `Option` instance is to treat it as a collection

```ruby
name = Fear.option(params[:name]) 
upper = name.map(&:strip).select { |n| n.length != 0 }.map(&:upcase)
puts upper.get_or_else('')
```

This allows for sophisticated chaining of `Option` values without
having to check for the existence of a value.

A less-idiomatic way to use `Option` values is via pattern matching

```ruby
case Fear.option(params[:name])
in Fear::Some(name) 
  name.strip.upcase
in Fear::None
  'No name value'
end
```

or manually checking for non emptiness

```ruby
name = Fear.option(params[:name])
if name.empty?
 puts 'No name value'
else
 puts name.strip.upcase
end
```

Alternatively, you can use camel-case factory methods `Fear::Option()`, `Fear::Some()` and `Fear::None` methods:

```ruby
Fear::Option(42) #=> #<Fear::Some get=42>
Fear::Option(nil) #=> #<Fear::None>

Fear::Some(42) #=> #<Fear::Some get=42>
Fear::Some(nil) #=> #<Fear::Some get=nil>
Fear::None #=> #<Fear::None>
``` 

#### Option#get_or_else

Returns the value from this `Some` or evaluates the given default argument if this is a `None`.

```ruby
Fear.some(42).get_or_else { 24/2 } #=> 42
Fear.none.get_or_else { 24/2 }   #=> 12

Fear.some(42).get_or_else(12)  #=> 42
Fear.none.get_or_else(12)    #=> 12
```

#### Option#or_else

returns self `Some` or the given alternative if this is a `None`.

```ruby
Fear.some(42).or_else { Fear.some(21) } #=> Fear.some(42)
Fear.none.or_else { Fear.some(21) }   #=> Fear.some(21)
Fear.none.or_else { None }     #=> None
```

#### Option#include?

Checks if `Option` has an element that is equal (as determined by `==`) to given values.

```ruby
Fear.some(17).include?(17) #=> true
Fear.some(17).include?(7)  #=> false
Fear.none.include?(17)   #=> false
```

#### Option#each

Performs the given block if this is a `Some`.

```ruby
Fear.some(17).each { |value| puts value } #=> prints 17
Fear.none.each { |value| puts value } #=> does nothing
```

#### Option#map 

Maps the given block to the value from this `Some` or returns self if this is a `None`

```ruby
Fear.some(42).map { |v| v/2 } #=> Fear.some(21)
Fear.none.map { |v| v/2 }   #=> None
```

#### Option#flat_map

Returns the given block applied to the value from this `Some` or returns self if this is a `None`

```ruby
Fear.some(42).flat_map { |v| Fear.some(v/2) }   #=> Fear.some(21)
Fear.none.flat_map { |v| Fear.some(v/2) }     #=> None
```

#### Option#any?

Returns `false` if `None` or returns the result of the application of the given predicate to the `Some` value.

```ruby 
Fear.some(12).any? { |v| v > 10 }  #=> true
Fear.some(7).any? { |v| v > 10 }   #=> false
Fear.none.any? { |v| v > 10 }    #=> false
```

#### Option#select

Returns self if it is nonempty and applying the predicate to this `Option`'s value returns `true`. Otherwise, 
return `None`.

```ruby
Fear.some(42).select { |v| v > 40 } #=> Fear.some(42)
Fear.some(42).select { |v| v < 40 } #=> None
Fear.none.select { |v| v < 40 }   #=> None
```

#### Option#filter_map

Returns a new `Some` of truthy results (everything except `false` or `nil`) of
running the block or `None` otherwise.

```ruby
Fear.some(42).filter_map { |v| v/2 if v.even? } #=> Fear.some(21)
Fear.some(42).filter_map { |v| v/2 if v.odd? } #=> Fear.none
Fear.some(42).filter_map { |v| false } #=> Fear.none
Fear.none.filter_map { |v| v/2 }   #=> Fear.none
```

#### Option#reject

Returns `Some` if applying the predicate to this `Option`'s value returns `false`. Otherwise, return `None`.

```ruby 
Fear.some(42).reject { |v| v > 40 } #=> None
Fear.some(42).reject { |v| v < 40 } #=> Fear.some(42)
Fear.none.reject { |v| v < 40 }   #=> None
```

#### Option#get

Not an idiomatic way of using Option at all. Returns values of raise `NoSuchElementError` error if option is empty.
   
#### Option#empty?

Returns `true` if the `Option` is `None`, `false` otherwise.

```ruby
Fear.some(42).empty? #=> false
Fear.none.empty?   #=> true
```

#### Option#present?

Returns `false` if the `Option` is `None`, `true` otherwise.

```ruby
Fear.some(42).present? #=> true
Fear.none.present?   #=> false
```

#### Option#zip

Returns a `Fear::Some` formed from this Option and another Option by combining the corresponding elements in a pair. 
If either of the two options is empty, `Fear::None` is returned.

```ruby
Fear.some("foo").zip(Fear.some("bar")) #=> Fear.some(["foo", "bar"])
Fear.some("foo").zip(Fear.some("bar")) { |x, y| x + y } #=> Fear.some("foobar")
Fear.some("foo").zip(Fear.none) #=> Fear.none
Fear.none.zip(Fear.some("bar")) #=> Fear.none

```

@see https://github.com/scala/scala/blob/2.11.x/src/library/scala/Option.scala
 

### Try ([API Documentation](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/Try))

The `Try` represents a computation that may either result
in an exception, or return a successfully computed value. Instances of `Try`,
are either an instance of `Success` or `Failure`.

For example, `Try` can be used to perform division on a
user-defined input, without the need to do explicit
exception-handling in all of the places that an exception
might occur.

```ruby
dividend = Fear.try { Integer(params[:dividend]) }
divisor = Fear.try { Integer(params[:divisor]) }
problem = dividend.flat_map { |x| divisor.map { |y| x / y } }

case problem
in Fear::Success(result)
  puts "Result of #{dividend.get} / #{divisor.get} is: #{result}"
in Fear::Failure(ZeroDivisionError)
  puts "Division by zero is not allowed"
in Fear::Failure(exception)
  puts "You entered something wrong. Try again"
  puts "Info from the exception: #{exception.message}"
end
```

An important property of `Try` shown in the above example is its
ability to _pipeline_, or chain, operations, catching exceptions
along the way. The `flat_map` and `map` combinators in the above
example each essentially pass off either their successfully completed
value, wrapped in the `Success` type for it to be further operated
upon by the next combinator in the chain, or the exception wrapped
in the `Failure` type usually to be simply passed on down the chain.
Combinators such as `recover_with` and `recover` are designed to provide some
type of default behavior in the case of failure.

*NOTE*: Only non-fatal exceptions are caught by the combinators on `Try`.
Serious system errors, on the other hand, will be thrown.

Alternatively, include you can use camel-case factory method `Fear::Try()`:

```ruby
Fear::Try { 4/0 }  #=> #<Fear::Failure exception=...>
Fear::Try { 4/2 }  #=> #<Fear::Success value=2>
```

#### Try#get_or_else

Returns the value from this `Success` or evaluates the given default argument if this is a `Failure`.

```ruby
Fear.success(42).get_or_else { 24/2 }                #=> 42
Fear.failure(ArgumentError.new).get_or_else { 24/2 } #=> 12
```

#### Try#include?

Returns `true` if it has an element that is equal given values, `false` otherwise.

```ruby
Fear.success(17).include?(17)                #=> true
Fear.success(17).include?(7)                 #=> false
Fear.failure(ArgumentError.new).include?(17) #=> false
```

#### Try#each

Performs the given block if this is a `Success`. If block raise an error, 
then this method may raise an exception.

```ruby
Fear.success(17).each { |value| puts value }  #=> prints 17
Fear.failure(ArgumentError.new).each { |value| puts value } #=> does nothing
```

#### Try#map

Maps the given block to the value from this `Success` or returns self if this is a `Failure`.

```ruby
Fear.success(42).map { |v| v/2 }                 #=> Fear.success(21)
Fear.failure(ArgumentError.new).map { |v| v/2 }  #=> Fear.failure(ArgumentError.new)
```

#### Try#flat_map

Returns the given block applied to the value from this `Success`or returns self if this is a `Failure`.

```ruby
Fear.success(42).flat_map { |v| Fear.success(v/2) } #=> Fear.success(21)
Fear.failure(ArgumentError.new).flat_map { |v| Fear.success(v/2) } #=> Fear.failure(ArgumentError.new)
```

#### Try#to_option

Returns an `Some` containing the `Success` value or a `None` if this is a `Failure`.

```ruby
Fear.success(42).to_option                 #=> Fear.some(42)
Fear.failure(ArgumentError.new).to_option  #=> None
```

#### Try#any?

Returns `false` if `Failure` or returns the result of the application of the given predicate to the `Success` value.

```ruby
Fear.success(12).any? { |v| v > 10 }                #=> true
Fear.success(7).any? { |v| v > 10 }                 #=> false
Fear.failure(ArgumentError.new).any? { |v| v > 10 } #=> false
```

#### Try#success? and Try#failure?


```ruby
Fear.success(12).success? #=> true
Fear.success(12).failure? #=> true

Fear.failure(ArgumentError.new).success? #=> false
Fear.failure(ArgumentError.new).failure? #=> true
```

#### Try#get

Returns the value from this `Success` or raise the exception if this is a `Failure`.

```ruby
Fear.success(42).get                 #=> 42
Fear.failure(ArgumentError.new).get  #=> ArgumentError: ArgumentError
```

#### Try#or_else

Returns self `Try` if it's a `Success` or the given alternative if this is a `Failure`.

```ruby
Fear.success(42).or_else { Fear.success(-1) }                 #=> Fear.success(42)
Fear.failure(ArgumentError.new).or_else { Fear.success(-1) }  #=> Fear.success(-1)
Fear.failure(ArgumentError.new).or_else { Fear.try { 1/0 } }  #=> Fear.failure(ZeroDivisionError.new('divided by 0'))
```

#### Try#flatten

Transforms a nested `Try`, ie, a `Success` of `Success`, into an un-nested `Try`, ie, a `Success`.

```ruby
Fear.success(42).flatten                         #=> Fear.success(42)
Fear.success(Fear.success(42)).flatten                #=> Fear.success(42)
Fear.success(Fear.failure(ArgumentError.new)).flatten #=> Fear.failure(ArgumentError.new)
Fear.failure(ArgumentError.new).flatten { -1 }   #=> Fear.failure(ArgumentError.new)
```

#### Try#select

Converts this to a `Failure` if the predicate is not satisfied.

```ruby
Fear.success(42).select { |v| v > 40 }
  #=> Fear.success(42)
Fear.success(42).select { |v| v < 40 }
  #=> Fear.failure(Fear::NoSuchElementError.new("Predicate does not hold for 42"))
Fear.failure(ArgumentError.new).select { |v| v < 40 }
  #=> Fear.failure(ArgumentError.new)
```

#### Recovering from errors

There are two ways to recover from the error. `Try#recover_with` method  is like `flat_map` for the exception. And 
you can pattern match against the error!

```ruby
Fear.success(42).recover_with do |m|
  m.case(ZeroDivisionError) { Fear.success(0) }
end #=> Fear.success(42)

Fear.failure(ArgumentError.new).recover_with do |m|
  m.case(ZeroDivisionError) { Fear.success(0) }
  m.case(ArgumentError) { |error| Fear.success(error.class.name) }
end #=> Fear.success('ArgumentError')
```

If the block raises error, this new error returned as an result

```ruby
Fear.failure(ArgumentError.new).recover_with do
  raise
end #=> Fear.failure(RuntimeError)
```

The second possibility for recovery is `Try#recover` method. It is like `map` for the exception. And it's also heavely
relies on pattern matching.

```ruby
Fear.success(42).recover do |m|
  m.case(&:message)
end #=> Fear.success(42)

Fear.failure(ArgumentError.new).recover do |m|
  m.case(ZeroDivisionError) { 0 }
  m.case(&:message)
end #=> Fear.success('ArgumentError')
```

If the block raises an error, this new error returned as an result

```ruby
Fear.failure(ArgumentError.new).recover do |m|
  raise
end #=> Fear.failure(RuntimeError)
```

#### Try#to_either

Returns `Left` with exception if this is a `Failure`, otherwise returns `Right` with `Success` value.

```ruby
Fear.success(42).to_either                #=> Fear.right(42)
Fear.failure(ArgumentError.new).to_either #=> Fear.left(ArgumentError.new)
```

### Either ([API Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/Option))
  
Represents a value of one of two possible types (a disjoint union.)
An instance of `Either` is either an instance of `Left` or `Right`.

A common use of `Either` is as an alternative to `Option` for dealing
with possible missing values.  In this usage, `None` is replaced
with a `Left` which can contain useful information.
`Right` takes the place of `Some`. Convention dictates
that `Left` is used for failure and `Right` is used for Right.

For example, you could use `Either<String, Fixnum>` to `#select_or_else` whether a
received input is a +String+ or an +Fixnum+.

```ruby
in = Readline.readline('Type Either a string or an Int: ', true)
result = begin
  Fear.right(Integer(in))
rescue ArgumentError
  Fear.left(in)
end

case result
in Fear::Right(x)
  "You passed me the Int: #{x}, which I will increment. #{x} + 1 = #{x+1}"
in Fear::Left(x)
  "You passed me the String: #{x}"
end
```

Either is right-biased, which means that `Right` is assumed to be the default case to
operate on. If it is `Left`, operations like `#map`, `#flat_map`, ... return the `Left` value
unchanged.

Alternatively, you can use camel-case factory methods `Fear::Left()`, and `Fear::Right()`:

```ruby
Fear::Left(42)  #=> #<Fear::Left value=42>
Fear::Right(42)  #=> #<Fear::Right value=42>
```

#### Either#get_or_else

Returns the value from this `Right` or evaluates the given default argument if this is a `Left`.

```ruby
Fear.right(42).get_or_else { 24/2 }         #=> 42
Fear.left('undefined').get_or_else { 24/2 } #=> 12

Fear.right(42).get_or_else(12)         #=> 42
Fear.left('undefined').get_or_else(12) #=> 12
```

#### Either#or_else

Returns self `Right` or the given alternative if this is a `Left`.

```ruby
Fear.right(42).or_else { Fear.right(21) }           #=> Fear.right(42)
Fear.left('unknown').or_else { Fear.right(21) }     #=> Fear.right(21)
Fear.left('unknown').or_else { Fear.left('empty') } #=> Fear.left('empty')
```

#### Either#include?

Returns `true` if `Right` has an element that is equal to given value, `false` otherwise.

```ruby
Fear.right(17).include?(17)         #=> true
Fear.right(17).include?(7)          #=> false
Fear.left('undefined').include?(17) #=> false
```

#### Either#each

Performs the given block if this is a `Right`.

```ruby
Fear.right(17).each { |value| puts value } #=> prints 17
Fear.left('undefined').each { |value| puts value } #=> does nothing
```

#### Either#map

Maps the given block to the value from this `Right` or returns self if this is a `Left`.

```ruby
Fear.right(42).map { |v| v/2 }          #=> Fear.right(21)
Fear.left('undefined').map { |v| v/2 }  #=> Fear.left('undefined')
```

#### Either#flat_map

Returns the given block applied to the value from this `Right` or returns self if this is a `Left`.

```ruby
Fear.right(42).flat_map { |v| Fear.right(v/2) }         #=> Fear.right(21)
Fear.left('undefined').flat_map { |v| Fear.right(v/2) } #=> Fear.left('undefined')
```

#### Either#to_option

Returns an `Some` containing the `Right` value or a `None` if this is a `Left`.

```ruby
Fear.right(42).to_option          #=> Fear.some(42)
Fear.left('undefined').to_option  #=> Fear::None
```

#### Either#any?

Returns `false` if `Left` or returns the result of the application of the given predicate to the `Right` value.

```ruby
Fear.right(12).any? { |v| v > 10 }         #=> true
Fear.right(7).any? { |v| v > 10 }          #=> false
Fear.left('undefined').any? { |v| v > 10 } #=> false
```

#### Either#right?, Either#success?

Returns `true` if this is a `Right`, `false` otherwise.

```ruby
Fear.right(42).right?   #=> true
Fear.left('err').right? #=> false
```

#### Either#left?, Either#failure?

Returns `true` if this is a `Left`, `false` otherwise.

```ruby
Fear.right(42).left?   #=> false
Fear.left('err').left? #=> true
```

#### Either#select_or_else

Returns `Left` of the default if the given predicate does not hold for the right value, otherwise, 
returns `Right`.

```ruby
Fear.right(12).select_or_else(-1, &:even?)       #=> Fear.right(12)
Fear.right(7).select_or_else(-1, &:even?)        #=> Fear.left(-1)
Fear.left(12).select_or_else(-1, &:even?)        #=> Fear.left(12)
Fear.left(12).select_or_else(-> { -1 }, &:even?) #=> Fear.left(12)
```

#### Either#select

Returns `Left` of value if the given predicate does not hold for the right value, otherwise, returns `Right`.

```ruby
Fear.right(12).select(&:even?) #=> Fear.right(12)
Fear.right(7).select(&:even?)  #=> Fear.left(7)
Fear.left(12).select(&:even?)  #=> Fear.left(12)
Fear.left(7).select(&:even?)   #=> Fear.left(7)
```

#### Either#reject

Returns `Left` of value if the given predicate holds for the right value, otherwise, returns `Right`.

```ruby
Fear.right(12).reject(&:even?) #=> Fear.left(12)
Fear.right(7).reject(&:even?)  #=> Fear.right(7)
Fear.left(12).reject(&:even?)  #=> Fear.left(12)
Fear.left(7).reject(&:even?)   #=> Fear.left(7)
```

#### Either#swap

If this is a `Left`, then return the left value in `Right` or vice versa.

```ruby
Fear.left('left').swap   #=> Fear.right('left')
Fear.right('right').swap #=> Fear.left('left')
```

#### Either#reduce

Applies `reduce_left` if this is a `Left` or `reduce_right` if this is a `Right`.

```ruby
result = possibly_failing_operation()
log(
  result.reduce(
    ->(ex) { "Operation failed with #{ex}" },
    ->(v) { "Operation produced value: #{v}" },
  )
)
```

#### Either#join_right

Joins an `Either` through `Right`. This method requires that the right side of this `Either` is itself an
`Either` type. This method, and `join_left`, are analogous to `Option#flatten`

```ruby
Fear.right(Fear.right(12)).join_right      #=> Fear.right(12)
Fear.right(Fear.left("flower")).join_right #=> Fear.left("flower")
Fear.left("flower").join_right        #=> Fear.left("flower")
Fear.left(Fear.right("flower")).join_right #=> Fear.left(Fear.right("flower"))
```

#### Either#join_left

Joins an `Either` through `Left`. This method requires that the left side of this `Either` is itself an
`Either` type. This method, and `join_right`, are analogous to `Option#flatten`

```ruby
Fear.left(Fear.right("flower")).join_left #=> Fear.right("flower")
Fear.left(Fear.left(12)).join_left        #=> Fear.left(12)
Fear.right("daisy").join_left        #=> Fear.right("daisy")
Fear.right(Fear.left("daisy")).join_left  #=> Fear.right(Fear.left("daisy"))
```

### Future ([API Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/Future))

Asynchronous computations that yield futures are created
with the `Fear.future` call

```ruby
success = "Hello"
f = Fear.future { success + ' future!' }
f.on_success do |result|
  puts result
end
```

Multiple callbacks may be registered; there is no guarantee
that they will be executed in a particular order.

The future may contain an exception and this means
that the future failed. Futures obtained through combinators
have the same error as the future they were obtained from.

```ruby 
f = Fear.future { 5 }
g = Fear.future { 3 }

f.flat_map do |x|
  g.map { |y| x + y }
end
```

Futures use [Concurrent::Promise](https://ruby-concurrency.github.io/concurrent-ruby/1.1.5/Concurrent/Promise.html#constructor_details)
under the hood. `Fear.future` accepts optional configuration Hash passed directly to underlying promise. For example, 
run it on custom thread pool.

```ruby
require 'open-uri'
pool = Concurrent::FixedThreadPool.new(5)
future = Fear.future(executor: pool) { open('https://example.com/') }
future.map(&:read).each do |body| 
  puts "#{body}"
end

``` 

Futures support common monadic operations -- `#map`, `#flat_map`, and `#each`. That's why it's possible to combine them 
using `Fear.for`, It returns the Future containing Success of `5 + 3` eventually.

```ruby 
f = Fear.future { 5 }
g = Fear.future { 3 }

Fear.for(f, g) do |x, y|
  x + y
end 
``` 

Future goes with the number of callbacks. You can register several callbacks, but the order of execution isn't guaranteed 

```ruby
f = Fear.future { ... } #  call external service
f.on_success do |result|
  # handle service response
end

f.on_failure do |error|
  # handle exception
end
```

or you can wait for Future completion

```ruby 
f.on_complete do |result|
  result.match do |m|
    m.success { |value| ... }
    m.failure { |error| ... }
  end
end 
```

In sake of convenience `#on_success` callback aliased as `#each`.

It's possible to get future value directly, but since it may be incomplete, `#value` method returns `Fear::Option`. So, 
there are three possible responses:

```ruby 
future.value #=>
# Fear::Some<Fear::Success> #=> future completed with value
# Fear::Some<Fear::Failure> #=> future completed with error
# Fear::None #=> future not yet completed
```    

There is a variety of methods to manipulate with futures. 

```ruby
Fear.future { open('http://example.com').read }
  .transform(
     ->(value) { ... },
     ->(error) { ... },
  )

future = Fear.future { 5 }
future.select(&:odd?) # evaluates to Fear.success(5)
future.select(&:even?) # evaluates to Fear.error(NoSuchElementError)
```

You can zip several asynchronous computations into one future. For you can call two external services and 
then zip the results into one future containing array of both responses:  

```ruby 
future1 = Fear.future { call_service1 }
future1 = Fear.future { call_service2 }
future1.zip(future2)
``` 

It  returns the same result as `Fear.future { [call_service1, call_service2] }`,  but the first version performs
two simultaneous calls.

There are two ways to recover from failure. `Future#recover` is live `#map` for failures:

```ruby
Fear.future { 2 / 0 }.recover do |m|
  m.case(ZeroDivisionError) { 0 }
end #=> returns new future of Fear.success(0)
```

If the future resolved to success or recovery matcher did not matched, it returns the future `Fear::Failure`.

The second option is `Future#fallback_to` method. It allows to fallback to result of another future in case of failure

```ruby
future = Fear.future { fail 'error' }
fallback = Fear.future { 5 }
future.fallback_to(fallback) # evaluates to 5
```

You can run callbacks in specific order using `#and_then` method:

```ruby 
f = Fear.future { 5 }
f.and_then do
  fail 'runtime error'
end.and_then do |m|
  m.success { |value| puts value } # it evaluates this branch
  m.failure { |error| puts error.massage }
end
```

#### Testing future values

Sometimes it may be helpful to await for future completion. You can await either future,
or result. Don't forget to pass timeout in seconds:


```ruby 
future = Fear.future { 42 }

Fear::Await.result(future, 3) #=> 42

Fear::Await.ready(future, 3) #=> Fear::Future.successful(42)
```

### For composition ([API Documentation](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/ForApi))

Provides syntactic sugar for composition of multiple monadic operations. 
It supports two such operations - `flat_map` and `map`. Any class providing them
is supported by `For`.

```ruby
Fear.for(Fear.some(2), Fear.some(3)) do |a, b|
  a * b
end #=> Fear.some(6)
```

If one of operands is None, the result is None

```ruby
Fear.for(Fear.some(2), None) do |a, b| 
  a * b 
end #=> None

Fear.for(None, Fear.some(2)) do |a, b| 
  a * b 
end #=> None
```

Lets look at first example:

```ruby
Fear.for(Fear.some(2), None) do |a, b| 
  a * b 
end #=> None
```

it is translated to:

```ruby
Fear.some(2).flat_map do |a|
  Fear.some(3).map do |b|
    a * b
  end
end
```

It works with arrays as well

```ruby
Fear.for([1, 2], [2, 3], [3, 4]) { |a, b, c| a * b * c }
  #=> [6, 8, 9, 12, 12, 16, 18, 24]

```

it is translated to:

```ruby
[1, 2].flat_map do |a|
  [2, 3].flat_map do |b|
    [3, 4].map do |c|
      a * b * c
    end
  end
end
```

If you pass lambda as a variable value, it would be evaluated
only on demand.

```ruby
Fear.for(proc { None }, proc { raise 'kaboom' } ) do |a, b|
  a * b
end #=> None
```

It does not fail since `b` is not evaluated.
You can refer to previously defined variables from within lambdas.

```ruby
maybe_user = find_user('Paul') #=> <#Option value=<#User ...>>

Fear.for(maybe_user, ->(user) { user.birthday }) do |user, birthday|
  "#{user.name} was born on #{birthday}"
end #=> Fear.some('Paul was born on 1987-06-17')
```

### Pattern Matching ([API Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/PatternMatchingApi))

#### Syntax

To pattern match against a value, use `Fear.match` function, and provide at least one case clause:

```ruby 
x = Random.rand(10)

Fear.match(x) do |m|
  m.case(0) { 'zero' }
  m.case(1) { 'one' }
  m.case(2) { 'two' }
  m.else { 'many' }
end
```

The `x` above is a random integer from 0 to 10. The last clause `else` is a “catch all” case 
for anything other than `0`, `1`, and `2`. If you want to ensure that an Integer value is passed,
matching against type available:

```ruby 
Fear.match(x) do |m|
  m.case(Integer, 0) { 'zero' }
  m.case(Integer, 1) { 'one' }
  m.case(Integer, 2) { 'two' }
  m.case(Integer) { 'many' }
end
```

Providing  something other than Integer will raise `Fear::MatchError` error.

#### Pattern guards 

You can use whatever you want as a pattern guard, if it respond to `#===` method to to make cases more specific. 

```ruby
m.case(20..40) { |m| "#{m} is within range" }
m.case(->(x) { x > 10}) { |m| "#{m} is greater than 10" } 
m.case(:even?.to_proc) { |x| "#{x} is even" }
m.case(:odd?.to_proc) { |x| "#{x} is odd" }
```

It's also possible to create matcher and use it several times:

```ruby
matcher = Fear.matcher do |m|
  m.case(Integer) { |n| "#{n} is a number" }
  m.case(String) { |n| "#{n} is a string" }
  m.else  { |n| "#{n} is a #{n.class}" }
end 

matcher.(42) #=> "42 is a number"
matcher.(10..20) #=> "10..20 is a Range"
``` 

#### How to debug pattern extractors?

You can build pattern manually and ask for failure reason:

```ruby
Fear['Some([:err, 444])'].failure_reason(Fear.some([:err, 445]))
# =>
Expected `445` to match:
Some([:err, 444])
~~~~~~~~~~~~^
```

by the way you can also match against such pattern

```ruby
Fear['Some([:err, 444])'] === Fear.some([:err, 445]) #=> false
Fear['Some([:err, 444])'] === Fear.some([:err, 445]) #=> true
```

#### More examples

Factorial using pattern matching

```ruby
factorial = Fear.matcher do |m|
  m.case(->(n) { n <= 1} ) { 1 }
  m.else { |n| n * factorial.(n - 1) }
end

factorial.(10) #=> 3628800
```

Fibonacci number

```ruby
fibonacci = Fear.matcher do |m|
  m.case(0) { 0 }
  m.case(1) { 1 }
  m.case(->(n) { n > 1}) { |n| fibonacci.(n - 1) + fibonacci.(n - 2) }
end

fibonacci.(10) #=> 55
```

Binary tree set implemented using pattern matching https://gist.github.com/bolshakov/3c51bbf7be95066d55d6d1ac8c605a1d

#### Monads pattern matching 

You can use `Option#match`, `Either#match`, and `Try#match` method. It performs matching not 
only on container itself, but on enclosed value as well. 

Pattern match against an `Option`

```ruby
Fear.some(42).match do |m|
  m.some { |x| x * 2 }
  m.none { 'none' }
end #=> 84
```

pattern match on enclosed value

```ruby
Fear.some(41).match do |m|
  m.some(:even?.to_proc) { |x| x / 2 }
  m.some(:odd?.to_proc, ->(v) { v > 0 }) { |x| x * 2 }
  m.none { 'none' }
end #=> 82
``` 

it raises `Fear::MatchError` error if nothing matched. To avoid exception, you can pass `#else` branch

```ruby
Fear.some(42).match do |m|
  m.some(:odd?.to_proc) { |x| x * 2 }
  m.else { 'nothing' }
end #=> nothing
```

Pattern matching works the similar way for `Either` and `Try` monads.

In sake of performance, you may want to generate pattern matching function and reuse it multiple times:

```ruby
matcher = Fear::Option.matcher do |m|
  m.some(42) { 'Yep' }
  m.some { 'Nope' }
  m.none { 'Error' } 
end

matcher.(Fear.some(42)) #=> 'Yep'
matcher.(Fear.some(40)) #=> 'Nope'
``` 

#### Under the hood 

Pattern matcher is a combination of partial functions wrapped into nice DSL. Every partial function 
defined on domain described with a guard.

```ruby
pf = Fear.case(Integer) { |x| x / 2 }
pf.defined_at?(4) #=> true
pf.defined_at?('Foo') #=> false
pf.call('Foo') #=> raises Fear::MatchError
pf.call_or_else('Foo') { 'not a number' } #=> 'not a number'
pf.call_or_else(4) { 'not a number' } #=> 2
pf.lift.call('Foo') #=> Fear::None
pf.lift.call(4) #=> Fear.some(2)
```

It uses `#===` method under the hood, so you can pass:

* Class to check kind of an object.
* Lambda to evaluate it against an object.
* Any literal, like `4`, `"Foobar"`, `:not_found` etc.
* Qo matcher -- `m.case(Qo[name: 'John']) { .... }`
 
Partial functions may be combined with each other:

```ruby
is_even = Fear.case(->(arg) { arg % 2 == 0}) { |arg| "#{arg} is even" }
is_odd = Fear.case(->(arg) { arg % 2 == 1}) { |arg| "#{arg} is odd" }

(10..20).map(&is_even.or_else(is_odd))

to_integer = Fear.case(String, &:to_i)
integer_two_times = Fear.case(Integer) { |x| x * 2 }

two_times = to_integer.and_then(integer_two_times).or_else(integer_two_times)
two_times.(4) #=> 8
two_times.('42') #=> 84
```

Since matcher is just a syntactic sugar for partial functions, you can combine matchers with partial
functions and each other. 

```ruby
handle_numbers = Fear.case(Integer, &:itself).and_then(
  Fear.matcher do |m|
    m.case(0) { 'zero' }
    m.case(->(n) { n < 10 }) { 'smaller than ten' }  
    m.case(->(n) { n > 10 }) { 'bigger than ten' }
  end
)

handle_strings = Fear.case(String, &:itself).and_then(
  Fear.matcher do |m|
    m.case('zero') { 0 }
    m.case('one') { 1 }
    m.else { 'unexpected' }
  end
)

handle = handle_numbers.or_else(handle_strings)
handle.(0) #=> 'zero'
handle.(12) #=> 'bigger than ten'
handle.('one') #=> 1
```

### Native pattern-matching 

Starting from ruby 2.7 you can use native pattern matching capabilities:

```ruby 
case Fear.some(42)
in Fear::Some(x)
  x * 2
in Fear::None 
  'none'
end #=> 84

case Fear.some(41)
in Fear::Some(x) if x.even?
  x / 2
in Fear::Some(x) if x.odd? && x > 0
  x * 2
in Fear::None
  'none'
end #=> 82

case Fear.some(42)
in Fear::Some(x) if x.odd?
  x * 2 
else 
  'nothing'
end #=> nothing
```

It's possible to pattern match against Fear::Either and Fear::Try as well:

```ruby 
case either 
in Fear::Right(Integer | String => x)
  "integer or string: #{x}"
in Fear::Left(String => error_code) if error_code = :not_found 
  'not found'
end  
```

```ruby 
case Fear.try { 10 / x } 
in Fear::Failure(ZeroDivisionError)
  # ..
in Fear::Success(x) 
  # ..
end  
```

### Dry-Types integration

#### Option

    NOTE: Requires the dry-tyes gem to be loaded.

Load the `:fear_option` extension in your application.

```ruby
require 'dry-types'
require 'dry/types/fear'

Dry::Types.load_extensions(:fear_option)

module Types
  include Dry.Types()
end
```

Append .option to a Type to return a `Fear::Option` object:

```ruby
Types::Option::Strict::Integer[nil] 
#=> Fear.none
Types::Option::Coercible::String[nil] 
#=> Fear.none
Types::Option::Strict::Integer[123] 
#=> Fear.some(123)
Types::Option::Strict::String[123]
#=> Fear.some(123)
Types::Option::Coercible::Float['12.3'] 
#=> Fear.some(12.3)
```

'Option' types can also accessed by calling '.option' on a regular type:

```ruby
Types::Strict::Integer.option # equivalent to Types::Option::Strict::Integer
```


You can define your own optional types:

```ruby
option_string = Types::Strict::String.option
option_string[nil]
# => Fear.none
option_string[nil].map(&:upcase)
# => Fear.none
option_string['something']
# => Fear.some('something')
option_string['something'].map(&:upcase)
# => Fear.some('SOMETHING')
option_string['something'].map(&:upcase).get_or_else { 'NOTHING' }
# => "SOMETHING"
```

You can use it with dry-struct as well:

```ruby
class User < Dry::Struct
  attribute :name, Types::Coercible::String
  attribute :age,  Types::Coercible::Integer.option
end

user = User.new(name: 'Bob', age: nil)
user.name #=> "Bob"
user.age #=> Fear.none 

user = User.new(name: 'Bob', age: 42)
user.age #=> Fear.some(42) 
```

## Testing

To simplify testing, you may use [fear-rspec](https://github.com/bolshakov/fear-rspec) gem. It
provides a bunch of rspec matchers.

## Contributing

1. Fork it ( https://github.com/bolshakov/fear/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Alternatives

* [algebrick](https://github.com/pitr-ch/algebrick)
* [deterministic](https://github.com/pzol/deterministic)
* [dry-monads](https://github.com/dry-rb/dry-monads)
* [kleisli](https://github.com/txus/kleisli)
* [maybe](https://github.com/bhb/maybe)
* [ruby-possibly](https://github.com/rap1ds/ruby-possibly)
* [rumonade](https://github.com/ms-ati/rumonade)
