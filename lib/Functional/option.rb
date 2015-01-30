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
    def defined?
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
      fail ArgumentError, '#get_or_else: block should be passed' unless block_given?
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
  end
end
