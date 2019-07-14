# frozen_string_literal: true

RSpec.describe Fear::For do
  context "unary" do
    context "Some" do
      subject do
        Fear.for(Fear.some(2)) { |a| a * 2 }
      end

      it { is_expected.to eq(Fear.some(4)) }
    end

    context "None" do
      subject do
        Fear.for(Fear.none) { |a| a * 2 }
      end

      it { is_expected.to eq(Fear.none) }
    end
  end

  context "arrays" do
    subject do
      Fear.for([1, 2], [2, 3], [3, 4]) do |a, b, c|
        a * b * c
      end
    end

    it { is_expected.to eq([6, 8, 9, 12, 12, 16, 18, 24]) }
  end

  context "ternary" do
    subject do
      Fear.for(first, second, third) do |a, b, c|
        a * b * c
      end
    end

    context "all Same" do
      let(:first) { Fear.some(2) }
      let(:second) { Fear.some(3) }
      let(:third) { Fear.some(4) }

      it { is_expected.to eq(Fear.some(24)) }
    end

    context "first is None" do
      let(:first) { Fear.none }
      let(:second) { Fear.some(3) }
      let(:third) { Fear.some(4) }

      it { is_expected.to eq(Fear.none) }
    end

    context "second is None" do
      let(:first) { Fear.some(2) }
      let(:second) { Fear.none }
      let(:third) { Fear.some(4) }

      it { is_expected.to eq(Fear.none) }
    end

    context "last is None" do
      let(:first) { Fear.some(2) }
      let(:second) { Fear.some(3) }
      let(:third) { Fear.none }

      it { is_expected.to eq(Fear.none) }
    end

    context "all Same in lambdas" do
      let(:first) { proc { Fear.some(2) } }
      let(:second) { proc { Fear.some(3) } }
      let(:third) { proc { Fear.some(4) } }

      it { is_expected.to eq(Fear.some(24)) }
    end

    context "first is None in lambda, second is failure in lambda" do
      let(:first) { proc { Fear.none } }
      let(:second) { proc { raise "kaboom" } }
      let(:third) { proc {} }

      it "returns None without evaluating second and third" do
        is_expected.to eq(Fear.none)
      end
    end

    context "second is None in lambda, third is failure in lambda" do
      let(:first) { Fear.some(2) }
      let(:second) { proc { Fear.none } }
      let(:third) { proc { raise "kaboom" } }

      it "returns None without evaluating third" do
        is_expected.to eq(Fear.none)
      end
    end
  end

  context "refer to previous variable from lambda" do
    subject do
      Fear.for(first, second, third) do |_, b, c|
        b * c
      end
    end

    let(:first) { Fear.some(Fear.some(2)) }
    let(:second) { ->(a) { a.map { |x| x * 2 } } }
    let(:third) { proc { Fear.some(3) } }

    it { is_expected.to eq(Fear.some(12)) }
  end
end
