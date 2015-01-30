module Functional
  class None
    include Option

    def empty?
      true
    end

    def get
      fail NoMethodError, 'None#get'
    end
  end
end
