# frozen_string_literal: true

RSpec.describe Fear::Option do
  describe "#zip" do
    subject { left.zip(right) }

    context "some with some" do
      let(:left) { Fear.some(42) }
      let(:right) { Fear.some(664) }

      it { is_expected.to eq(Fear.some([42, 664])) }
    end

    context "some with none" do
      let(:left) { Fear.some(42) }
      let(:right) { Fear.none }

      it { is_expected.to eq(Fear.none) }
    end

    context "none with some" do
      let(:left) { Fear.none }
      let(:right) { Fear.some(42) }

      it { is_expected.to eq(Fear.none) }
    end

    context "none with none" do
      let(:left) { Fear.none }
      let(:right) { Fear.none }

      it { is_expected.to eq(Fear.none) }
    end
  end
end
