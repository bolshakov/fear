# frozen_string_literal: true

require "fear/awaitable"

RSpec.describe Fear::Awaitable do
  subject(:awaitable) { Object.new.extend(Fear::Awaitable) }

  describe "#__ready__" do
    it "must implement the method" do
      expect { awaitable.__ready__(1) }.to raise_error(NotImplementedError)
    end
  end

  describe "#__result__" do
    it "must implement the method" do
      expect { awaitable.__result__(1) }.to raise_error(NotImplementedError)
    end
  end
end
