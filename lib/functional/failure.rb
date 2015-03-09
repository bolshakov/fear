module Functional
  class Failure
    include Try

    def initialize(exception)
      @exception = exception
    end

    attr_reader :exception

    def success?
      false
    end

    def get
      fail exception
    end

    def ==(other)
      other.is_a?(Failure) && exception == other.exception
    end
  end
end
