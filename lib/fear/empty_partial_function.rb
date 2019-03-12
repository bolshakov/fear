module Fear
  # Use singleton version of EmptyPartialFunction -- PartialFunction::EMPTY
  # @api private
  class EmptyPartialFunction
    include PartialFunction

    def initialize; end

    def defined_at?(_)
      false
    end

    def call(arg)
      raise MatchError, "partial function not defined at: #{arg}"
    end

    alias === call
    alias [] call

    def call_or_else(arg)
      yield arg
    end

    def or_else(other)
      other
    end

    def and_then(*)
      self
    end

    def to_s
      'Empty partial function'
    end
  end

  private_constant :EmptyPartialFunction
end
