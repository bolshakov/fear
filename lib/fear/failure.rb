# frozen_string_literal: true

module Fear
  class Failure
    include Try
    include RightBiased::Left
    include FailurePatternMatch.mixin

    EXTRACTOR = proc do |try|
      if Fear::Failure === try
        Fear.some([try.exception])
      else
        Fear.none
      end
    end
    public_constant :EXTRACTOR

    # @param [StandardError]
    def initialize(exception)
      @exception = exception
    end

    attr_reader :exception

    # @return [Boolean]
    def success?
      false
    end

    # @return [true]
    def failure?
      true
    end

    # @raise
    def get
      raise exception
    end

    # @return [Try] of calling block
    def or_else(*args)
      super
    rescue StandardError => error
      Failure.new(error)
    end

    # @return [Failure] self
    def flatten
      self
    end

    # @return [Failure] self
    def select
      self
    end

    # @yieldparam [Fear::PatternMatch]
    # @yieldreturn [Fear::Try]
    # @return [Fear::Try]
    def recover_with
      Fear.matcher { |m| yield(m) }
        .and_then { |result| result.tap { Utils.assert_type!(result, Success, Failure) } }
        .call_or_else(exception) { self }
    rescue StandardError => error
      Failure.new(error)
    end

    # @yieldparam [Fear::PatternMatch]
    # @yieldreturn [any]
    # @return [Fear::Try]
    def recover
      Fear.matcher { |m| yield(m) }
        .and_then { |v| Success.new(v) }
        .call_or_else(exception) { self }
    rescue StandardError => error
      Failure.new(error)
    end

    # @return [Left]
    def to_either
      Left.new(exception)
    end

    # @param other [Any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(Failure) && exception == other.exception
    end

    # Used in case statement
    # @param other [any]
    # @return [Boolean]
    def ===(other)
      if other.is_a?(Failure)
        exception === other.exception
      else
        super
      end
    end

    # @return [String]
    def inspect
      "#<Fear::Failure exception=#{exception.inspect}>"
    end

    # @return [String]
    alias to_s inspect
  end
end
