module Functional
  class Success
    include Try

    attr_reader :get

    def initialize(value)
      @get = value
    end

    def success?
      true
    end

    def ==(other)
      other.is_a?(Success) && get == other.get
    end
  end
end
