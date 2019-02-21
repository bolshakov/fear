module Fear
  class None
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
  end
end
