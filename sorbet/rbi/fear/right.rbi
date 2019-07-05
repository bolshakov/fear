# typed: true
require 'sorbet-runtime'

module Fear
  class Right
    extend T::Sig
    extend T::Generic
    include Either
    include RightBiased::Right
    LeftValue = type_member
    RightValue = type_member

    sig { params(value: RightValue).void }
    def initialize(value)
    end
  end
end
