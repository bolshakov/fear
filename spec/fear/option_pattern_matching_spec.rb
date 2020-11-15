# frozen_string_literal: true

RSpec.describe Fear::Option do
  describe "pattern matching" do
    subject do
      case value
      in Fear::Some(Integer => int)
        "some of #{int}"
      in Fear::None
        "none"
      else
        "something else"
      end
    end

    context "when value is some of integer" do
      let(:value) { Fear.some(42) }

      it { is_expected.to eq("some of 42") }
    end

    context "when value is none" do
      let(:value) { Fear.none }

      it { is_expected.to eq("none") }
    end

    context "when value is not some of integer" do
      let(:value) { Fear.some("42") }

      it { is_expected.to eq("something else") }
    end
  end
end
