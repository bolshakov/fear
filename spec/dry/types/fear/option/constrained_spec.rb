# frozen_string_literal: true

require "support/dry_types"

RSpec.describe Dry::Types::Constrained, :option do
  context "with a option type" do
    subject(:type) do
      Dry::Types["nominal.string"].constrained(size: 4).option
    end

    it_behaves_like "Dry::Types::Nominal without primitive"

    it "passes when constraints are not violated" do
      expect(type[nil]).to be_none
      expect(type["hell"]).to be_some_of("hell")
    end

    it "raises when a given constraint is violated" do
      expect { type["hel"] }.to raise_error(Dry::Types::ConstraintError, /hel/)
    end
  end
end
