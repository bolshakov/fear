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

    def ==(other)
      if other.is_a?(Some)
        get == other.get
      else
        false
      end
    end

    def eql?(other)
      if other.is_a?(Some)
        get.eql?(other.get)
      else
        false
      end
    end
  end
end
