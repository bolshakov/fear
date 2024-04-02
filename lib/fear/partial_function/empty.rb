# frozen_string_literal: true

module Fear
  module PartialFunction
    Empty = EmptyPartialFunction.new
    Empty.freeze

    public_constant :Empty
  end
end
