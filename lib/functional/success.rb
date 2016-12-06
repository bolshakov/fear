module Functional
  class Success
    include Try
    include Dry::Equalizer(:value)
    include RightBiased::Right

    attr_reader :value
    protected :value

    def initialize(value)
      @value = value
    end

    def get
      @value
    end

    def success?
      true
    end
  end
end
