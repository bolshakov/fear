module Functional
  module Option
    def self.empty
      None()
    end

    def empty?
      fail NotImplementedError
    end

    def defined?
      !empty?
    end
  end
end
