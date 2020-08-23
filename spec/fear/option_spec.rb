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

  describe "#filter_map" do
    subject { option.filter_map(&filter_map) }

    context "some mapped to nil" do
      let(:option) { Fear.some(42) }
      let(:filter_map) { ->(*) { nil } }

      it { is_expected.to be_none }
    end

    context "some mapped to false" do
      let(:option) { Fear.some(42) }
      let(:filter_map) { ->(*) { false } }

      it { is_expected.to be_none }
    end

    context "some mapped to true" do
      let(:option) { Fear.some(42) }
      let(:filter_map) { ->(*) { true } }

      it { is_expected.to be_some_of(true) }
    end

    context "some mapped to another value" do
      let(:option) { Fear.some(42) }
      let(:filter_map) { ->(x) { x / 2 if x.even? } }

      it { is_expected.to be_some_of(21) }
    end

    context "none" do
      let(:option) { Fear.none }
      let(:filter_map) { ->(x) { x / 2 } }

      it { is_expected.to be_none }
    end
  end
end
