module Functional
  class Some < Struct.new(:value)
    include Option

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
