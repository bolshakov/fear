# Fear
[![Build Status](https://travis-ci.org/bolshakov/fear.svg?branch=master)](https://travis-ci.org/bolshakov/fear)

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

### Option

Represents optional values. Instances of `Option` are either an instance of 
`Some` or the object `None`.

The most idiomatic way to use an `Option` instance is to treat it
as a collection and use `map`, `flat_map`, `select`, or `each`:

```ruby
name = Option(params[:name])
upper = name.map(&:strip).select { |n| n.length != 0 }.map(&:upcase)
puts upper.get_or_else('')
```

This allows for sophisticated chaining of `Option` values without
having to check for the existence of a value.

See full documentation [Fear::Option](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/Option)

### Try

The `Try` represents a computation that may either result in an exception, 
or return a successfully computed value.  Instances of `Try`, are either 
an instance of `Success` or `Failure`.

For example, `Try` can be used to perform division on a user-defined input, 
without the need to do explicit exception-handling in all of the places 
that an exception might occur.

```ruby
dividend = Try { Integer(params[:dividend]) }
divisor = Try { Integer(params[:divisor]) }

problem = dividend.flat_map { |x| divisor.map { |y| x / y }

if problem.success?
  puts "Result of #{dividend.get} / #{divisor.get} is: #{problem.get}"
else
  puts "You must've divided by zero or entered something wrong. Try again"
  puts "Info from the exception: #{problem.exception.message}"
end
```
See full documentation [Fear::Try](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/Try)

### Either

Represents a value of one of two possible types (a disjoint union.)
An instance of `Either` is either an instance of `Left` or `Right`.

A common use of `Either` is as an alternative to `Option` for dealing
with possible missing values.  In this usage, `None` is replaced
with a `Left` which can contain useful information.
`Right` takes the place of `Some`. Convention dictates
that `Left` is used for failure and `Right` is used for success.

For example, you could use `Either<String, Fixnum>` to select whether a
received input is a `String` or an `Fixnum`.

```ruby
input = Readline.readline('Type Either a string or an Int: ', true)
result = begin
  Right(Integer(input))
rescue ArgumentError
  Left(input)
end

puts(
  result.reduce(
    -> (x) { "You passed me the Int: #{x}, which I will increment. #{x} + 1 = #{x+1}" },
    -> (x) { "You passed me the String: #{x}" }
  )
)
```
  
See full documentation [Fear::Either](http://www.rubydoc.info/github/bolshakov/fear/master/Fear/Either)
  
### For composition

Provides syntactic sugar for composition of multiple monadic operations. 
It supports two such operations - `flat_map` and `map`. Any class providing them
is supported by `For`.

```ruby
For(a: Some(2), b: Some(3)) do 
  a * b 
end #=> Some(6)
```

It would be translated to 

```ruby
Some(2).flat_map do |a|
  Some(3).map do |b|
    a * b
  end
end
```

If one of operands is None, the result is None

```ruby
For(a: Some(2), b: None()) do
  a * b
end  #=> None()

For(a: None(), b: Some(2)) do 
  a * b 
end #=> None()
```

`For` works with arrays as well

```ruby
For(a: [1, 2], b: [2, 3], c: [3, 4]) do 
  a * b * c
end #=> [6, 8, 9, 12, 12, 16, 18, 24]
```
 
would be translated to:

```ruby
[1, 2].flat_map do |a|
  [2, 3].flat_map do |b|
    [3, 4].map do |c|
      a * b * c
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/bolshakov/fear/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
