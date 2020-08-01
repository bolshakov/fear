# frozen_string_literal: true

require "support/dry_types"

RSpec.describe Dry::Types::Nominal, "#default", :option do
  context "with a maybe" do
    subject(:type) { Dry::Types["strict.integer"].option }

    it_behaves_like "Dry::Types::Nominal without primitive" do
      let(:type) { Dry::Types["strict.integer"].option.default(0) }
    end

    it "does not allow nil" do
      expect { type.default(nil) }.to raise_error(ArgumentError, /nil/)
    end

    it "accepts a non-nil value" do
      expect(type.default(0)[0]).to be_some_of(0)
    end
  end
end
