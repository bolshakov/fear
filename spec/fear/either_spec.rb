# frozen_string_literal: true

RSpec.describe Fear::Either do
  describe "#matcher" do
    subject(:result) { matcher.call(value) }

    let(:matcher) do
      described_class.matcher do |m|
        m.right { |x| "right of #{x}" }
        m.left { |x| "left of #{x}" }
      end
    end

    context "when matches the right branch" do
      let(:value) { Fear.right(42) }

      it { is_expected.to eq("right of 42") }
    end

    context "when matches the left branch" do
      let(:value) { Fear.left(42) }

      it { is_expected.to eq("left of 42") }
    end
  end
end
