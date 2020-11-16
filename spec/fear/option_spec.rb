# frozen_string_literal: true

RSpec.describe Fear::Option do
  describe "#zip" do
    subject(:zip) { left.zip(right) }

    context "some with some" do
      let(:left) { Fear.some(42) }
      let(:right) { Fear.some(664) }

      context "without a block" do
        subject { left.zip(right) }

        it { is_expected.to eq(Fear.some([42, 664])) }
      end

      context "with a block" do
        subject { left.zip(right) { |x, y| x * y } }

        it { is_expected.to eq(Fear.some(27_888)) }
      end
    end

    context "some with none" do
      let(:left) { Fear.some(42) }
      let(:right) { Fear.none }

      it { is_expected.to eq(Fear.none) }
    end

    context "some with non-option" do
      let(:left) { Fear.some(42) }
      let(:right) { 42 }

      it { expect { zip }.to raise_error(TypeError) }
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

    context "none with non-option" do
      let(:left) { Fear.none }
      let(:right) { 42 }

      it { expect { zip }.to raise_error(TypeError) }
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

  describe "#matcher" do
    subject(:result) { matcher.(value) }

    let(:matcher) do
      described_class.matcher do |m|
        m.some { |x| "some of #{x}" }
        m.none { "none" }
      end
    end

    context "when matches some branch" do
      let(:value) { Fear.some(42) }

      it { is_expected.to eq("some of 42") }
    end

    context "when matches none branch" do
      let(:value) { Fear.none }

      it { is_expected.to eq("none") }
    end
  end

  describe "#match" do
    subject(:matcher) do
      described_class.match(value) do |m|
        m.some { |x| "some of #{x}" }
        m.none { "none" }
      end
    end

    context "when matches some branch" do
      let(:value) { Fear.some(42) }

      it { is_expected.to eq("some of 42") }
    end

    context "when matches none branch" do
      let(:value) { Fear.none }

      it { is_expected.to eq("none") }
    end
  end
end
