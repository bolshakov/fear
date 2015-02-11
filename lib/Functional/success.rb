module Functional
  class Success
    include Try

    def initialize(value)
      @value = value
    end

    attr_reader :value
    protected :value

    def failure?
      false
    end

    def success?
      true
    end

    def get
      value
    end
  end
end
