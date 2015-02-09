module Functional
  class Some
    include Option

    attr_reader :value
    protected :value

    def initialize(value)
      @value = value
    end

    def empty?
      false
    end

    def get
      value
    end

    def ==(that)
      if that.is_a?(Some)
        value == that.value
      else
        false
      end
    end

    def eql?(that)
      if that.is_a?(Some)
        value.eql?(that.value)
      else
        false
      end
    end
  end
end
