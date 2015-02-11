module Functional
  module Try
    # Returns `true` if the `Try` is a `Failure`, `false` otherwise.
    #
    def failure?
      fail NotImplementedError, "#{self.class.name}#failure?"
    end

    # Returns `true` if the `Try` is a `Success`, `false` otherwise.
    #
    def success?
      fail NotImplementedError, "#{self.class.name}#success?"
    end

    # Returns the value from this `Success` or throws the exception if
    # this is a `Failure`.
    #
    def get
      fail NotImplementedError, "#{self.class.name}#get?"
    end
  end
end
