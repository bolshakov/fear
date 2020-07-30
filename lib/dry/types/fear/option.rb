# frozen_string_literal: true

module Dry
  module Types
    class Option
      include Type
      include ::Dry::Equalizer(:type, :options, inspect: false, immutable: true)
      include Decorator
      include Builder
      include Printable

      # @param [Fear::Option, Object] input
      #
      # @return [Fear::Option]
      #
      # @api private
      def call_unsafe(input = Undefined)
        case input
        when ::Fear::Option
          input
        when Undefined
          Fear.none
        else
          Fear.option(type.call_unsafe(input))
        end
      end

      # @param [Fear::Option, Object] input
      #
      # @return [Fear::Option]
      #
      # @api private
      def call_safe(input = Undefined)
        case input
        when ::Fear::Option
          input
        when Undefined
          Fear.none
        else
          Fear.option(type.call_safe(input) { |output = input| return yield(output) })
        end
      end

      # @param [Object] input
      #
      # @return [Result::Success]
      #
      # @api public
      def try(input = Undefined)
        result = type.try(input)

        if result.success?
          Result::Success.new(Fear.option(result.input))
        else
          result
        end
      end

      # @return [true]
      #
      # @api public
      def default?
        true
      end

      # @param [Object] value
      #
      # @see Dry::Types::Builder#default
      #
      # @raise [ArgumentError] if nil provided as default value
      #
      # @api public
      def default(value)
        if value.nil?
          raise ArgumentError, "nil cannot be used as a default of a maybe type"
        else
          super
        end
      end
    end

    module Builder
      # Turn a type into a maybe type
      #
      # @return [Option]
      #
      # @api public
      def option
        Option.new(Types["nil"] | self)
      end
    end

    # @api private
    class Schema
      class Key
        # @api private
        def option
          __new__(type.option)
        end
      end
    end

    # @api private
    class Printer
      MAPPING[Option] = :visit_option

      # @api private
      def visit_option(maybe)
        visit(maybe.type) do |type|
          yield "Fear::Option<#{type}>"
        end
      end
    end

    # Register non-coercible maybe types
    NON_NIL.each_key do |name|
      register("option.strict.#{name}", self[name.to_s].option)
    end

    # Register coercible maybe types
    COERCIBLE.each_key do |name|
      register("option.coercible.#{name}", self["coercible.#{name}"].option)
    end
  end
end
