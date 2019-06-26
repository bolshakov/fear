# typed: true
module Fear
  module OptionApi
    extend T::Sig
    sig do
      type_parameters(:T)
        .params(value: T.nilable(T.type_parameter(:T)))
        .returns(Option[T.type_parameter(:T)])
    end
    def option(value)
    end

    sig do
      type_parameters(:T)
        .params(value: T.type_parameter(:T))
        .returns(Some[T.type_parameter(:T)])
    end
    def some(value)
    end

    sig do
      returns(NoneClass[NilClass])
    end
    def none
    end
  end
end
