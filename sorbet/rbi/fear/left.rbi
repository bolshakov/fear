# typed: true
require 'sorbet-runtime'

module Fear
  class Left
    extend T::Sig
    extend T::Generic
    include Either
    include RightBiased::Right
    LeftValue = type_member
    RightValue = type_member

    sig { params(value: LeftValue).void }
    def initialize(value)
    end
  end
end
