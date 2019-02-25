module Fear
  # @api private
  class NoneClass
    include Option
    include Dry::Equalizer()
    include RightBiased::Left

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

    AS_STRING = 'Fear::None'.freeze

    # @return [String]
    def to_s
      AS_STRING
    end

    # @return [String]
    def inspect
      AS_STRING
    end
  end

  private_constant(:NoneClass)

  # The only instance of NoneClass
  None = NoneClass.new.freeze

  class << NoneClass
    def new
      None
    end

    def inherited
      raise 'you are not allowed to inherit from NoneClass, use Fear::None instead'
    end
  end
end
