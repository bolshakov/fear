# typed: true
module Fear
  class NoneClass
    extend T::Sig
    extend T::Generic
    include Option
    Value = type_member
  end
  #
  class << self
    sig { params(base: T.untyped).returns(T.noreturn) }
    def inherited(base)
    end
  end
end
