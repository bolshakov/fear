module Functional
  module Option
    def self.empty
      None()
    end

    # Returns true if the option is None, false otherwise.
    #
    def empty?
      fail NotImplementedError, "#{self.class.name}#empty?"
    end

    # Returns true if the option is an instance of Some, false otherwise.
    #
    def present?
      !empty?
    end

    # Returns the option's value.
    #
    def get
      fail NotImplementedError, "#{self.class.name}#get"
    end

    # Returns the option's value if the option is nonempty, otherwise
    # return the result of evaluating `default`.
    #
    def get_or_else(&default)
      fail ArgumentError, '#get_or_else: no block given' unless block_given?
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
      fail ArgumentError, '#map: no block given' unless block_given?
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
      fail ArgumentError, '#inject: no block given' unless block_given?
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
      fail ArgumentError, '#filter: no block given' unless block_given?
      if(present? && predicate.call(get))
        self
      else
        None()
      end
    end

    # Returns this option if it is nonempty and applying the predicate to
    # this option's value returns false. Otherwise, return none.
    #
    def reject(&predicate)
      fail ArgumentError, '#reject: no block given' unless block_given?
      if(present? && !predicate.call(get))
        self
      else
        None()
      end
    end
  end
end
