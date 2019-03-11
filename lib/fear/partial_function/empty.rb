module Fear
  module PartialFunction
    EMPTY = Object.new.extend(EmptyPartialFunction)
    EMPTY.freeze
  end
end
