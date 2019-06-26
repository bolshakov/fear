# typed: true
module Fear
  # You're strongly discouraged to use this module since it may lead to deadlocks,
  # and reduced performance. Although, blocking may be useful in some cases (e.g. in tests)
  #
  # @see https://stackoverflow.com/questions/38155159/why-doesnt-scalas-future-have-a-get-getmaxduration-method-forcing-us-to
  module Await
    # Blocks until +Fear::Awaitable+ reached completed state and returns itself
    # or raises +TimeoutError+
    #
    # @param awaitable [Fear::Awaitable]
    # @param at_most [Fixnum] timeout in seconds
    # @return [Fear::Awaitable]
    # @raise [Timeout::Error]
    #
    module_function def ready(awaitable, at_most)
      awaitable.__ready__(at_most)
    end

    # Blocks until +Fear::Awaitable+ reached completed state and returns its value
    # or raises +TimeoutError+
    #
    # @param awaitable [Fear::Awaitable]
    # @param at_most [Fixnum] timeout in seconds
    # @return [any]
    # @raise [Timeout::Error]
    #
    module_function def result(awaitable, at_most)
      awaitable.__result__(at_most)
    end
  end
end
