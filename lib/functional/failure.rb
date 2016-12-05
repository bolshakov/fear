module Functional
  class Failure
    include Try
    include Dry::Equalizer(:exception)

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
  end
end
