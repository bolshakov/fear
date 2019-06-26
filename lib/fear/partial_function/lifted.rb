# typed: false
module Fear
  module PartialFunction
    # @api private
    class Lifted
      # @param pf [Fear::PartialFunction]
      def initialize(pf)
        @pf = pf
      end
      attr_reader :pf
      private :pf

      # @param arg [any]
      # @return [Fear::Option]
      def call(arg)
        Some.new(pf.call_or_else(arg) { return Fear::None })
      end
    end

    private_constant :Lifted
  end
end
