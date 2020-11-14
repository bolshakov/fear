# frozen_string_literal: true

module Fear
  module PartialFunction
    EMPTY = EmptyPartialFunction.new
    EMPTY.freeze

    public_constant :EMPTY
  end
end
