module Functional
  # Represents optional values. Instances of `Option`
  #  are either an instance of $some or the object $none.
  #
  #  The most idiomatic way to use an $option instance is to treat it
  #  as a collection or monad and use `map`,`flat_map`, `select`, or
  #  `each`:
  #
  #  {{{
  #  name = Option(params[:name])
  #  upper = name.map(&:strip).select { |n| n.length != 0 }.map(&:upcase)
  #  puts upper.get_or_else('')
  #  }}}
  #
  #  Because of how for comprehension works, if $none is returned
  #  from `Option(params[:name])`, the entire expression results in
  #  $none
  #
  #  This allows for sophisticated chaining of $option values without
  #  having to check for the existence of a value.
  #
  #  A less-idiomatic way to use $option values is via pattern matching: {{{
  #  name_maybe = Option(params[:name])
  #  case name_maybe
  #  when Some
  #    puts name.strip.upcase
  #  when None
  #    puts 'No name value'
  #  end
  #  }}}
  #
  #  @note Many of the methods in here are duplicative with those
  #  in the Traversable hierarchy, but they are duplicated for a reason:
  #  the implicit conversion tends to leave one with an Iterable in
  #  situations where one could have retained an Option.
  #
  module Option
    BLOCK_REQUIRED = 'block required'.freeze

    def self.empty
      None()
    end

    # Returns true if the option is None, false otherwise.
    #
    def empty?
      assert_method_defined!('empty?')
    end

    # Returns true if the option is an instance of Some, false otherwise.
    #
    def present?
      !empty?
    end

    # Returns the option's value.
    #
    def get
      assert_method_defined!('get')
    end

    # Returns the option's value if the option is nonempty, otherwise
    # return `default`.
    #
    def get_or_else(&default)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if empty?
        default.call
      else
        get
      end
    end

    # Returns the option's value if it is nonempty,
    # or `nil` if it is empty.
    #
    def or_nil
      get_or_else { nil }
    end

    # Returns a Some containing the result of applying `block` to this option's
    # value if this Option is nonempty.
    # Otherwise return None.
    #
    def map(&block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if empty?
        None()
      else
        Some(block.call(get))
      end
    end

    # Returns the result of applying `block` to this option's
    # value if the option is nonempty.  Otherwise, evaluates
    # expression `if_empty`.
    #
    def inject(if_empty, &block)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if empty?
        if_empty
      else
        block.call(get)
      end
    end

    # Returns this option if it is nonempty and applying the predicate to
    # this option's value returns true. Otherwise, return none.
    #
    def select(&predicate)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if present? && predicate.call(get)
        self
      else
        None()
      end
    end

    # Returns this option if it is nonempty and applying the predicate to
    # this option's value returns false. Otherwise, return none.
    #
    def reject(&predicate)
      fail ArgumentError, BLOCK_REQUIRED unless block_given?

      if present? && !predicate.call(get)
        self
      else
        None()
      end
    end

    private

    def assert_method_defined!(method)
      fail NotImplementedError, "#{self.class.name}##{method}"
    end
  end
end
