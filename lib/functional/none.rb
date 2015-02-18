module Functional
  class None
    include Option

    def empty?
      true
    end

    def get
      fail NoMethodError, 'None#get'
    end

    def ==(that)
      that.is_a?(None)
    end

    def eql?(that)
      that.is_a?(None)
    end
  end
end
