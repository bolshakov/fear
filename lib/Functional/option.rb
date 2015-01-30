module Functional
  module Option
    def self.empty
      None()
    end

    def empty?
      fail NotImplementedError, "#{self.class.name}#empty?"
    end

    def defined?
      !empty?
    end

    def get
      fail NotImplementedError, "#{self.class.name}#get"
    end
  end
end
