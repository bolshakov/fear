module Functional
  class Some
    include Option
    include Dry::Equalizer(:get)

    # @!attribute get
    #   @return option's value
    attr_reader :get

    def initialize(value)
      @get = value
    end

    def empty?
      false
    end
  end
end
