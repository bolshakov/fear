# frozen_string_literal: true

require "support/dry_types"

RSpec.describe Dry::Types::Nominal, "#option", :option do
  context "with a nominal" do
    subject(:type) { Dry::Types["nominal.string"].option }

    it_behaves_like "Dry::Types::Nominal without primitive"

    it "returns None when value is nil" do
      expect(type[nil]).to be_none
    end

    it "returns Some when value exists" do
      expect(type["hello"]).to be_some_of("hello")
    end

    it "returns original if input is already a option" do
      expect(type[Fear.some("hello")]).to be_some_of("hello")
    end

    it "aliases #[] as #call" do
      expect(type.("hello")).to be_some_of("hello")
    end

    it "does not have primitive" do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context "with a strict type" do
    subject(:type) { Dry::Types["strict.integer"].option }

    it_behaves_like "Dry::Types::Nominal without primitive"

    it "returns None when value is nil" do
      expect(type[nil]).to be_none
    end

    it "returns Some when value exists" do
      expect(type[231]).to be_some_of(231)
    end
  end

  context "with a sum" do
    subject(:type) { Dry::Types["nominal.bool"].option }

    it_behaves_like "Dry::Types::Nominal without primitive"

    it "returns None when value is nil" do
      expect(type[nil]).to be_none
    end

    it "returns Some when value exists" do
      expect(type[true]).to be_some_of(true)
      expect(type[false]).to be_some_of(false)
    end

    it "does not have primitive" do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context "with keys" do
    subject(:type) do
      Dry::Types["hash"].schema(foo: Dry::Types["integer"]).key(:foo)
    end

    it "gets wrapped by key type" do
      expect(type.option).to be_a(Dry::Types::Schema::Key)
      expect(type.option[nil]).to be_none
      expect(type.option[1]).to be_some_of(1)
    end
  end

  describe "#try" do
    subject(:type) { Dry::Types["coercible.integer"].option }

    it "maps successful result" do
      expect(type.try("1")).to eq(Dry::Types::Result::Success.new(Fear.some(1)))
      expect(type.try(nil)).to eq(Dry::Types::Result::Success.new(Fear.none))
      expect(type.try("a")).to be_a(Dry::Types::Result::Failure)
    end
  end

  describe "#call" do
    describe "safe calls" do
      subject(:type) { Dry::Types["coercible.integer"].option }

      specify do
        expect(type.("a") { :fallback }).to be(:fallback)
        expect(type.(Fear.some(1)) { :fallback }).to eq(Fear.some(1))
      end
    end
  end
end
