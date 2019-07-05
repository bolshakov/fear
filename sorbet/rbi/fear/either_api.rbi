# typed: true
module Fear
  module EitherApi
    extend T::Sig

    sig do
      type_parameters(:L, :R)
        .params(value: T.type_parameter(:L))
        .returns(Either[T.type_parameter(:L), T.type_parameter(:R)])
    end
    def left(value)
    end

    sig do
      type_parameters(:L, :R)
        .params(value: T.type_parameter(:R))
        .returns(Either[T.type_parameter(:L), T.type_parameter(:R)])
    end
    def right(value)
    end
  end
end
