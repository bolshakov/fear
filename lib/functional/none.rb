module Functional
  class None
    include Option

    def empty?
      true
    end

    # @raise [NoMethodError]
    #
    def get
      fail NoMethodError, 'None#get'
    end

    def ==(other)
      other.is_a?(None)
    end

    def eql?(other)
      other.is_a?(None)
    end
  end
end
