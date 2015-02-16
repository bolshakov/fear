module Functional
  class Failure
    include Try

    def initialize(exception)
      @exception = exception
    end

    attr_reader :exception
    protected :exception

    def failure?
      true
    end

    def success?
      false
    end

    def get
      fail exception
    end

    def ==(other)
      self.exception == other.exception
    end
  end
end
