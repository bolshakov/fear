# typed: true
require 'sorbet-runtime'
module Fear
  class Some
    extend T::Sig
    extend T::Generic
    include Option
    include RightBiased::Right
    Value = type_member

    sig { params(value: Value).void}
    def initialize(value)
    end
  end
end
