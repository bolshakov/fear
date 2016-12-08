module Fear
  class None
    include Option
    include Dry::Equalizer()
    include RightBiased::Left

    # Ignores the given block and return self.
    #
    # @return [None]
    #
    def select(*)
      self
    end

    # Ignores the given block and return self.
    #
    # @return [None]
    #
    def reject(*)
      self
    end
  end
end
