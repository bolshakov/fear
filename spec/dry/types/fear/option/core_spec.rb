# frozen_string_literal: true

require "support/dry_types"

RSpec.describe Dry::Types::Nominal, :option do
  describe "with opt-in option types" do
    context "with strict string" do
      let(:string) { Dry::Types["option.strict.string"] }

      it_behaves_like "Dry::Types::Nominal without primitive" do
        let(:type) { string }
      end

      it "accepts nil" do
        expect(string[nil]).to be_none
      end

      it "accepts a string" do
        expect(string["something"]).to be_some_of("something")
      end
    end

    context "with coercible string" do
      let(:string) { Dry::Types["option.coercible.string"] }

      it_behaves_like "Dry::Types::Nominal without primitive" do
        let(:type) { string }
      end

      it "accepts nil" do
        expect(string[nil]).to be_none
      end

      it "accepts a string" do
        expect(string[:something]).to be_some_of("something")
      end
    end
  end

  describe "defining coercible Option String" do
    let(:option_string) { Dry::Types["coercible.string"].option }

    it_behaves_like "Dry::Types::Nominal without primitive" do
      let(:type) { option_string }
    end

    it "accepts nil" do
      expect(option_string[nil]).to be_none
    end

    it "accepts an object coercible to a string" do
      expect(option_string[123]).to be_some_of("123")
    end
  end

  describe "defining Option String" do
    let(:option_string) { Dry::Types["strict.string"].option }

    it_behaves_like "Dry::Types::Nominal without primitive" do
      let(:type) { option_string }
    end

    it "accepts nil and returns None instance" do
      value = option_string[nil]

      expect(value).to be_none
      expect(value.map(&:downcase).map(&:upcase)).to be_none
    end

    it "accepts a string and returns Some instance" do
      value = option_string["SomeThing"]

      expect(value).to be_some_of("SomeThing")
      expect(value.map(&:downcase).map(&:upcase)).to be_some_of("SOMETHING")
    end
  end
end
