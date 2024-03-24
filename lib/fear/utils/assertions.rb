# frozen_string_literal: true

module Fear
  module Utils
    # @api private
    module Assertions
      def assert_return(expected_type, method_name)
        alias_method "#{method_name}_without_return_type_check", method_name

        define_method(method_name) do |*args, &block|
          result = __send__("#{method_name}_without_return_type_check", *args, &block)

          unless expected_type === result
            raise TypeError, "#{self.class}##{method_name} expected to return #{expected_type.inspect}, " \
              "but returned #{result.inspect}"
          end

          result
        end
      end

      def assert_arg_or_block(method_name)
        alias_method "#{method_name}_without_arg_or_block_check", method_name

        define_method(method_name) do |*args, &block|
          unless !block.nil? ^ !args.empty?
            raise ArgumentError, "##{method_name} accepts either one argument or block"
          end

          __send__("#{method_name}_without_arg_or_block_check", *args, &block)
        end
      end
    end
  end
end
