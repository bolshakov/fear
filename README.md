# Fear
[![Build Status](https://travis-ci.org/bolshakov/fear.svg?branch=master)](https://travis-ci.org/bolshakov/fear)
[![Gem Version](https://badge.fury.io/rb/fear.svg)](https://badge.fury.io/rb/fear)

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

* [Option](#option-documentation) 
* [Try](#try-documentation)
* [Either](#either-documentation)
* [For composition](#for-composition)
* [Pattern Matching](#pattern-matching-api-documentation)

### Option ([Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/OptionApi))

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
Fear.option(params[:name]).match do |m|
  m.some { |name| name.strip.upcase }
  m.none { 'No name value' }
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

Alternatively, include `Fear::Option::Mixin` to use `Option()`, `Some()` and `None()` methods:

```ruby
include Fear::Option::Mixin 

Option(42) #=> #<Fear::Some get=42>
Option(nil) #=> #<Fear::None>

Some(42) #=> #<Fear::Some get=42>
Some(nil) #=> #<Fear::Some get=nil>
None() #=> #<Fear::None>
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

#### Option#inlude?

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
Fear.some(12).any?( |v| v > 10)  #=> true
Fear.some(7).any?( |v| v > 10)   #=> false
Fear.none.any?( |v| v > 10)    #=> false
```

#### Option#select

Returns self if it is nonempty and applying the predicate to this `Option`'s value returns `true`. Otherwise, 
return `None`.

```ruby 
Fear.some(42).select { |v| v > 40 } #=> Fear.success(21)
Fear.some(42).select { |v| v < 40 } #=> None
Fear.none.select { |v| v < 40 }   #=> None
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

@see https://github.com/scala/scala/blob/2.11.x/src/library/scala/Option.scala
 

### Try ([API Documentation](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/TryApi))

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

problem.match |m|
  m.success do |result|
    puts "Result of #{dividend.get} / #{divisor.get} is: #{result}"
  end

  m.failure(ZeroDivisionError) do
    puts "Division by zero is not allowed"
  end

  m.failure do |exception|
    puts "You entered something wrong. Try again"
    puts "Info from the exception: #{exception.message}"
  end
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

Alternatively, include `Fear::Try::Mixin` to use `Try()` method:

```ruby
include Fear::Try::Mixin 

Try { 4/0 }  #=> #<Fear::Failure exception=...>
Try { 4/2 }  #=> #<Fear::Success value=2>
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
Fear.success(42).to_option                 #=> Fear.some(21)
Fear.failure(ArgumentError.new).to_option  #=> None
```

#### Try#any?

Returns `false` if `Failure` or returns the result of the application of the given predicate to the `Success` value.

```ruby
Fear.success(12).any?( |v| v > 10)                #=> true
Fear.success(7).any?( |v| v > 10)                 #=> false
Fear.failure(ArgumentError.new).any?( |v| v > 10) #=> false
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
  #=> Fear.success(21)
Fear.success(42).select { |v| v < 40 }
  #=> Fear.failure(Fear::NoSuchElementError.new("Predicate does not hold for 42"))
Fear.failure(ArgumentError.new).select { |v| v < 40 }
  #=> Fear.failure(ArgumentError.new)
```

#### Try#recover_with

Applies the given block to exception. This is like `flat_map` for the exception.

```ruby
Fear.success(42).recover_with { |e| Fear.success(e.massage) }
  #=> Fear.success(42)
Fear.failure(ArgumentError.new).recover_with { |e| Fear.success(e.massage) }
  #=> Fear.success('ArgumentError')
Fear.failure(ArgumentError.new).recover_with { |e| raise }
  #=> Fear.failure(RuntimeError)
```

#### Try#recover

Applies the given block to exception. This is like `map` for the exception.

```ruby
Fear.success(42).recover { |e| e.massage }
  #=> Fear.success(42)
Fear.failure(ArgumentError.new).recover { |e| e.massage }
  #=> Fear.success('ArgumentError')
Fear.failure(ArgumentError.new).recover { |e| raise }
  #=> Fear.failure(RuntimeError)
```

#### Try#to_either

Returns `Left` with exception if this is a `Failure`, otherwise returns `Right` with `Success` value.

```ruby
Fear.success(42).to_either                #=> Fear.right(42)
Fear.failure(ArgumentError.new).to_either #=> Fear.left(ArgumentError.new)
```

### Either ([API Documentation](https://www.rubydoc.info/github/bolshakov/fear/master/Fear/EitherApi))
  
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

result.match do |m|
  m.right do |x|
    "You passed me the Int: #{x}, which I will increment. #{x} + 1 = #{x+1}"
  end

  m.left do |x|
    "You passed me the String: #{x}"
  end
end
```

Either is right-biased, which means that `Right` is assumed to be the default case to
operate on. If it is `Left`, operations like `#map`, `#flat_map`, ... return the `Left` value
unchanged.

Alternatively, include `Fear::Either::Mixin` to use `Left()`, and `Right()` methods:

```ruby
include Fear::Either::Mixin 

Left(42)  #=> #<Fear::Left value=42>
Right(42)  #=> #<Fear::Right value=42>
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
Fear.right(42).to_option          #=> Fear.some(21)
Fear.left('undefined').to_option  #=> Fear::None
```

#### Either#any?

Returns `false` if `Left` or returns the result of the application of the given predicate to the `Right` value.

```ruby
Fear.right(12).any?( |v| v > 10)         #=> true
Fear.right(7).any?( |v| v > 10)          #=> false
Fear.left('undefined').any?( |v| v > 10) #=> false
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

#### Either#join_right

Joins an `Either` through `Left`. This method requires that the left side of this `Either` is itself an
`Either` type. This method, and `join_right`, are analogous to `Option#flatten`

```ruby
Fear.left(Fear.right("flower")).join_left #=> Fear.right("flower")
Fear.left(Fear.left(12)).join_left        #=> Fear.left(12)
Fear.right("daisy").join_left        #=> Fear.right("daisy")
Fear.right(Fear.left("daisy")).join_left  #=> Fear.right(Fear.left("daisy"))
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

Pattern matcher is a combination of partial functions wrapped into nice DSL. Every partial function 
defined on domain described with guard.

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
* Any literal, like `4`, `"Foobar"`, etc.
* Symbol -- it is converted to lambda using `#to_proc` method.
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

To create custom pattern match use `Fear.match` method and `case` builder to define
branches. For instance this matcher applies different functions to Integers and Strings

```ruby 
Fear.match(value) do |m|
  m.case(Integer) { |n| "#{n} is a number" }
  m.case(String) { |n| "#{n} is a string" }
end
```

if you pass something other than Integer or string, it will raise `Fear::MatchError` error.
To avoid raising `MatchError`, you can use `else` method. It defines a branch matching
on any value.

```ruby 
Fear.match(10..20) do |m|
  m.case(Integer) { |n| "#{n} is a number" }
  m.case(String) { |n| "#{n} is a string" }
  m.else  { |n| "#{n} is a #{n.class}" }
end #=> "10..20 is a Range"
```

You can use anything as a guardian if it responds to `#===` method:

```ruby
m.case(20..40) { |m| "#{m} is within range" }
m.case(->(x) { x > 10}) { |m| "#{m} is greater than 10" }
```

If you pass a Symbol, it will be converted to proc using `#to_proc` method

```ruby 
m.case(:even?) { |x| "#{x} is even" }
m.case(:odd?) { |x| "#{x} is odd" }
```

It's also possible to pass several guardians. All should match to pass

```ruby 
m.case(Integer, :even?) { |x| ... }
m.case(Integer, :odd?) { |x| ... }
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
fibonnaci = Fear.matcher do |m|
  m.case(0) { 0 }
  m.case(1) { 1 }
  m.case(->(n) { n > 1}) { |n| fibonnaci.(n - 1) + fibonnaci.(n - 2) }
end

fibonnaci.(10) #=> 55
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
  m.some(:even?) { |x| x / 2 }
  m.some(:odd?, ->(v) { v > 0 }) { |x| x * 2 }
  m.none { 'none' }
end #=> 82
``` 

it raises `Fear::MatchError` error if nothing matched. To avoid exception, you can pass `#else` branch

```ruby
Fear.some(42).match do |m|
  m.some(:odd?) { |x| x * 2 }
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

* [deterministic](https://github.com/pzol/deterministic)
* [dry-monads](https://github.com/dry-rb/dry-monads)
* [kleisli](https://github.com/txus/kleisli)
* [maybe](https://github.com/bhb/maybe)
* [ruby-possibly](https://github.com/rap1ds/ruby-possibly)
* [rumonade](https://github.com/ms-ati/rumonade)
