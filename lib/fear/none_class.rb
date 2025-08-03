# frozen_string_literal: true

module Fear
  # @api private
  class NoneClass
    include Option
    include RightBiased::Left
    include PatternMatch.mixin

    class << self
      def inherited(*)
        raise "you are not allowed to inherit from NoneClass, use Fear::None instead"
      end
    end

    # @raise [NoSuchElementError]
    def get
      raise NoSuchElementError
    end

    # @return [nil]
    def or_nil
      nil
    end

    # @return [true]
    def empty?
      true
    end

    alias_method :blank?, :empty?

    # @return [false]
    def present?
      false
    end

    # @return [None]
    def select(*)
      self
    end

    # @return [None]
    def reject(*)
      self
    end

    # @return [String]
    def inspect
      "#<Fear::NoneClass>"
    end

    # @return [String]
    alias_method :to_s, :inspect

    # @param other [Any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(NoneClass)
    end

    # @param other
    # @return [Boolean]
    def ===(other)
      self == other
    end

    # @param other [Fear::Option]
    # @return [Fear::Option]
    def zip(other)
      if other.is_a?(Option)
        Fear.none
      else
        raise TypeError, "can't zip with #{other.class}"
      end
    end

    # @return [RightBiased::Left]
    def filter_map
      self
    end
  end

  private_constant(:NoneClass)
end
