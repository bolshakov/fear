module Functional
  module Utils
    extend self

    def assert_arg_or_block!(method_name, *args)
      unless block_given? ^ args.any?
        fail ArgumentError, "##{method_name} accepts either one argument or block"
      end
    end

    def assert_type!(value, type)
      unless value.is_a?(type)
        fail TypeError, "expected `#{value}` to be of #{type} class"
      end
    end
  end
end
