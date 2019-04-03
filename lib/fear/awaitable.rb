module Fear
  # An object which may eventually be completed and awaited using blocking methods.
  #
  # @abstract
  # @api private
  # @see Fear::Await
  module Awaitable
    # Await +completed+ state of this +Awaitable+
    #
    # @param at_most [Fixnum] maximum timeout in seconds
    # @return [Fear::Awaitable]
    # @raise [Timeout::Error]
    def __ready__(_at_most)
      raise NotImplementedError
    end

    # Await and return the result of this +Awaitable+
    #
    # @param at_most [Fixnum] maximum timeout in seconds
    # @return [any]
    # @raise [Timeout::Error]
    def __result__(_at_most)
      raise NotImplementedError
    end
  end
end
