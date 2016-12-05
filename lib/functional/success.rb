module Functional
  class Success
    include Try
    include Dry::Equalizer(:get)

    attr_reader :get

    def initialize(value)
      @get = value
    end

    def success?
      true
    end
  end
end
