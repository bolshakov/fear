# frozen_string_literal: true

RSpec.describe Fear::Either do
  describe "pattern matching" do
    subject do
      case value
      in Fear::Right[Integer => int]
        "right of #{int}"
      in Fear::Left[Integer => int]
        "left of #{int}"
      else
        "something else"
      end
    end

    context "when value is right of integer" do
      let(:value) { Fear.right(42) }

      it { is_expected.to eq("right of 42") }
    end

    context "when value is left of integer" do
      let(:value) { Fear.left(42) }

      it { is_expected.to eq("left of 42") }
    end
  end
end
