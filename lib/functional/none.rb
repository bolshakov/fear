module Functional
  class None
    include Option
    include Dry::Equalizer()

    def empty?
      true
    end

    # @raise [NoMethodError]
    #
    def get
      fail NoMethodError, 'None#get'
    end
  end
end
