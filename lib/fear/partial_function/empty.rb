# frozen_string_literal: true

require "fear/empty_partial_function"

module Fear
  module PartialFunction
    EMPTY = EmptyPartialFunction.new
    EMPTY.freeze

    public_constant :EMPTY
  end
end
