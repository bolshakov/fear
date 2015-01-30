module Functional
  class None
    include Option

    def empty?
      true
    end
  end
end
