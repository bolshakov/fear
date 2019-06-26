# typed: true
module Fear
  module PartialFunction
    # Any is an object which is always truthy
    # @api private
    class Any
      class << self
        # @param _other [any]
        # @return [true]
        def ===(_other)
          true
        end

        # @param _other [any]
        # @return [true]
        def ==(_other)
          true
        end

        # @return [Proc]
        def to_proc
          proc { true }
        end
      end
    end
  end
end
