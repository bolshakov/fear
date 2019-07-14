# frozen_string_literal: true

module Fear
  # @api private
  class NoneClass
    include Option
    include RightBiased::Left
    include NonePatternMatch.mixin

    EXTRACTOR = proc do |option|
      if Fear::None === option
        Fear.some([])
      else
        Fear.none
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
    alias to_s inspect

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
  end

  private_constant(:NoneClass)

  # The only instance of NoneClass
  None = NoneClass.new.freeze

  class << NoneClass
    def new
      None
    end

    def inherited(*)
      raise "you are not allowed to inherit from NoneClass, use Fear::None instead"
    end
  end
end
