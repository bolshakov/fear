module Functional
  class Some < Struct.new(:value)
    include Option

    def empty?
      false
    end
  end
end
