module Fear
  # rubocop: disable Metrics/LineLength
  module FutureApi
    # Asynchronously evaluates the block
    # @param options [Hash] options will be passed directly to underlying +Concurrent::Promise+
    #   @see https://ruby-concurrency.github.io/concurrent-ruby/1.1.5/Concurrent/Promise.html#constructor_details Constructor Details
    # @return [Fear::Future]
    #
    # @example
    #   require 'open-uri'
    #   f = Fear.future(executor: :io) { open('http://example.com') }
    #   f.map(&:read).each { |body| puts body }
    #
    def future(options = {}, &block)
      Future.new(options, &block)
    end
  end
  # rubocop: enable Metrics/LineLength
end
