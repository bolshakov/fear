module Functional
  class Failure
    include Try
    include Dry::Equalizer(:exception)
    include RightBiased::Left

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
