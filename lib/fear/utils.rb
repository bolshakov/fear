# frozen_string_literal: true

module Fear
  # @private
  module Utils
    EMPTY_STRING = ""
    public_constant :EMPTY_STRING

    IDENTITY = :itself.to_proc
    public_constant :IDENTITY

    UNDEFINED = Object.new.freeze
    public_constant :UNDEFINED

    EMPTY_HASH = {}.freeze
    public_constant :EMPTY_HASH

    EMPTY_ARRAY = [].freeze
    public_constant :EMPTY_ARRAY

    class << self
      def assert_arg_or_block!(method_name, *args)
        unless block_given? ^ !args.empty?
          raise ArgumentError, "##{method_name} accepts either one argument or block"
        end
      end

      def with_block_or_argument(method_name, arg = UNDEFINED, block = nil)
        if block.nil? ^ arg.equal?(UNDEFINED)
          yield(block || arg)
        else
          raise ArgumentError, "#{method_name} accepts either block or partial function"
        end
      end

      def assert_type!(value, *types)
        if types.none? { |type| value.is_a?(type) }
          raise TypeError, "expected `#{value.inspect}` to be of #{types.join(", ")} class"
        end
      end

      def return_or_call_proc(value)
        if value.respond_to?(:call)
          value.()
        else
          value
        end
      end
    end
  end
end
