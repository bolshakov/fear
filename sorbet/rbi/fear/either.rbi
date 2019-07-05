# typed: true
module Fear
  module Either
    extend T::Sig
    extend T::Generic
    LeftValue = type_member(:out)
    RightValue = type_member(:out)

    sig do
      type_parameters(:T)
        .params(default: T.proc.returns(T.type_parameter(:T)))
        .returns(T.any(RightValue, T.type_parameter(:T)))
    end
    def get_or_else(&default)
    end

    sig do
      type_parameters(:T)
        .params(other_value: T.type_parameter(:T))
        .returns(T::Boolean)
    end
    def include?(other_value)
    end

    sig do
      params(block: T.proc.params(arg0: RightValue).void)
        .returns(T.self_type)
    end
    def each(&block)
    end

    sig do
      type_parameters(:T)
        .params(block: T.proc.params(arg0: RightValue).returns(T.type_parameter(:T)))
        .returns(Either[LeftValue, T.type_parameter(:T)])
    end
    def map(&block)
    end

    sig do
      type_parameters(:T)
        .params(
          block: (
            T.proc
              .params(arg0: RightValue)
              .returns(Either[LeftValue, T.type_parameter(:T)])
          )
        )
        .returns(Either[LeftValue, T.type_parameter(:T)])
    end
    def flat_map(&block)
    end

    sig do
      returns(Option[RightValue])
    end
    def to_option
    end

    sig do
      type_parameters(:T)
        .params(predicate: T.proc.params(arg0: RightValue).returns(T::Boolean))
        .returns(T::Boolean)
    end
    def any?(&predicate)
    end

    sig { returns(T::Boolean) }
    def right?
    end

    sig { returns(T::Boolean) }
    def left?
    end

    sig do
      type_parameters(:T)
        .params(
          default: T.any(
            T.type_parameter(:T),
            T.proc.returns(T.type_parameter(:T)),
          ),
          predicate: T.proc.params(arg0: RightValue).returns(T::Boolean)
        )
        .returns(Either[T.any(LeftValue, T.type_parameter(:T)), RightValue])
    end
    def select_or_else(default, &predicate)
    end

    sig do
      params(predicate: T.proc.params(arg0: RightValue).returns(T::Boolean))
        .returns(T.self_type)
    end
    def select(&predicate)
    end

    sig do
      params(predicate: T.proc.params(arg0: RightValue).returns(T::Boolean))
        .returns(T.self_type)
    end
    def reject(&predicate)
    end

    sig do
      returns(T.self_type)
    end
    def swap(&predicate)
    end

    sig do
      type_parameters(:TL, :TR)
        .params(
          reduce_left: T.proc.params(arg0: LeftValue).returns(T.type_parameter(:TL)),
          reduce_right: T.proc.params(arg0: RightValue).returns(T.type_parameter(:TR)),
        )
        .returns(Either[T.type_parameter(:TL), T.type_parameter(:TR)])
    end
    def reduce(reduce_left,  reduce_right)
    end

    # ???
    def join_right
    end

    # sig do
    #   type_parameters(:T)
    #     .params(other: T.type_parameter(:T))
    #     .returns(T::Boolean)
    # end
    # def ===(other)
    # end
    #
    # sig do
    #   returns(T::Boolean)
    # end
    # def right?
    # end
    #
    # sig do
    #   returns(T::Boolean)
    # end
    # def left?
    # end
    #
    # sig do
    #   type_parameters(:T)
    #     .params(default: T.any(T.type_parameter(:T)))
    # end
    # def select_or_else(default, &predicate)
    # end
    #
    # sig { returns(String) }
    # def inspect
    # end
    #
    # sig do
    #   type_parameters(:T)
    #     .params(other: T.type_parameter(:T))
    #     .returns(T::Boolean)
    # end
    # def ==(other)
    # end
    #
    # # @!endgroup RightBiased
    #
    # # @!group Option
    # sig { returns(Value) }
    # def get
    # end
    #
    # sig { returns(T::Boolean) }
    # def empty?
    # end
    #

    #

    #
    # sig { returns(T.nilable(Value)) }
    # def or_nil
    # end
    #
    # # @!endgroup Option
    #
    # sig { returns(T.class_of(NoneClass)) }
    # def left_class
    # end
    #
    # sig { returns(T.class_of(Some)) }
    # def right_class
    # end

    # class << self
    #   extend T::Sig
    #
    #   sig do
    #     params(matcher: T.proc.params(arg0: OptionPatternMatch).void )
    #     .returns(PartialFunctionClass)
    #   end
    #   def matcher(&matcher)
    #   end
    #
    #   sig do
    #     type_parameters(:T, :U)
    #       .params(
    #         value: T.type_parameter(:T),
    #         block: T.proc.params(arg0: OptionPatternMatch).void )
    #       .returns(T.type_parameter(:U))
    #   end
    #   def match(value, &block)
    #   end
    # end

    # module Mixin
    #   extend T::Sig
    #   extend T::Generic
    #
    #   sig do
    #     type_parameters(:T)
    #       .params(value: T.nilable(T.type_parameter(:T)))
    #       .returns(Option[T.type_parameter(:T)])
    #   end
    #   def Option(value)
    #   end
    #
    #   sig do
    #     returns(NoneClass[NilClass])
    #   end
    #   def None
    #   end
    #
    #   sig do
    #     type_parameters(:T)
    #       .params(value: T.type_parameter(:T))
    #       .returns(Some[T.type_parameter(:T)])
    #   end
    #   def Some(value)
    #   end
    # end
  end
end
