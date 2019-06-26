# typed: true
module Fear
  module Option
    extend T::Sig
    extend T::Generic
    Value = type_member(:out)

    # @!group RightBiased
    sig do
      type_parameters(:T)
        .params(default: T.proc.returns(T.type_parameter(:T)))
        .returns(T.any(Value, T.type_parameter(:T)))
    end
    def get_or_else(&default)
    end


    sig do
      type_parameters(:T)
        .params(default: T.proc.returns(Option[T.type_parameter(:T)]))
        .returns(T.any(T.self_type, Option[T.type_parameter(:T)]))
    end
    def or_else(&default)
    end

    sig do
      type_parameters(:T)
        .params(other_value: T.type_parameter(:T))
        .returns(T::Boolean)
    end
    def include?(other_value)
    end

    sig do
      params(block: T.proc.params(arg0: Value).void)
        .returns(T.self_type)
    end
    def each(&block)
    end

    sig do
      type_parameters(:T)
        .params(block: T.proc.params(arg0: Value).returns(T.type_parameter(:T)))
        .returns(Option[T.type_parameter(:T)])
    end
    def map(&block)
    end

    sig do
      type_parameters(:T)
        .params(block: T.proc.params(arg0: Value).returns(Option[T.type_parameter(:T)]))
        .returns(Option[T.type_parameter(:T)])
    end
    def flat_map(&block)
    end

    sig do
      returns(T.self_type)
    end
    def to_option
    end

    sig do
      type_parameters(:T)
        .params(predicate: T.proc.params(arg0: Value).returns(T::Boolean))
        .returns(T::Boolean)
    end
    def any?(&predicate)
    end

    sig do
      type_parameters(:T)
        .params(other: T.type_parameter(:T))
        .returns(T::Boolean)
    end
    def ===(other)
    end

    sig { returns(String) }
    def inspect
    end

    sig do
      type_parameters(:T)
        .params(other: T.type_parameter(:T))
        .returns(T::Boolean)
    end
    def ==(other)
    end

    # @!endgroup RightBiased

    # @!group Option
    sig { returns(Value) }
    def get
    end

    sig { returns(T::Boolean) }
    def empty?
    end

    sig do
      params(predicate: T.proc.params(arg0: Value).returns(T::Boolean))
        .returns(Option[Value])
    end
    def select(&predicate)
    end

    sig do
      params(predicate: T.proc.params(arg0: Value).returns(T::Boolean))
        .returns(Option[Value])
    end
    def reject(&predicate)
    end

    sig { returns(T.nilable(Value)) }
    def or_nil
    end

    # @!endgroup Option

    sig { returns(T.class_of(NoneClass)) }
    def left_class
    end

    sig { returns(T.class_of(Some)) }
    def right_class
    end

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

    module Mixin
      extend T::Sig
      extend T::Generic

      sig do
        type_parameters(:T)
          .params(value: T.nilable(T.type_parameter(:T)))
          .returns(Option[T.type_parameter(:T)])
      end
      def Option(value)
      end

      sig do
        returns(NoneClass[NilClass])
      end
      def None
      end

      sig do
        type_parameters(:T)
          .params(value: T.type_parameter(:T))
          .returns(Some[T.type_parameter(:T)])
      end
      def Some(value)
      end
    end
  end
end
