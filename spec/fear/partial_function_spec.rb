# frozen_string_literal: true

RSpec.describe Fear::PartialFunction do
  describe "Fear.case()" do
    context "condition as symbol" do
      subject { Fear.case(:even?) { |x| x } }

      it "matches against the same symbol" do
        is_expected.to be_defined_at(:even?)
        is_expected.not_to be_defined_at(3)
      end
    end

    context "condition as Class" do
      subject { Fear.case(Integer) { |x| x } }

      it do
        is_expected.to be_defined_at(4)
        is_expected.not_to be_defined_at("3")
      end
    end

    context "condition as Proc" do
      subject { Fear.case(->(x) { x.even? }) { |x| x } }

      it do
        is_expected.to be_defined_at(4)
        is_expected.not_to be_defined_at(3)
      end
    end

    context "multiple condition" do
      subject { Fear.case(Integer, :even?.to_proc, ->(x) { x % 3 == 0 }) { |x| x } }

      it do
        is_expected.to be_defined_at(12)
        is_expected.not_to be_defined_at(12.0)
        is_expected.not_to be_defined_at("3")
        is_expected.not_to be_defined_at(3)
        is_expected.not_to be_defined_at(4)
      end
    end

    context "multiple condition 2" do
      subject { Fear.case(Integer, 4) { |x| x } }

      it do
        is_expected.to be_defined_at(4)
        is_expected.not_to be_defined_at(3)
      end
    end
  end

  describe ".or" do
    subject { described_class.or(guard_1, guard_2, &:itself) }

    let(:guard_1) { ->(x) { x == 42 } }
    let(:guard_2) { ->(x) { x == 21 } }

    it { is_expected.to be_defined_at(42) }
    it { is_expected.to be_defined_at(21) }
    it { is_expected.not_to be_defined_at(20) }
  end

  describe ".and" do
    subject { described_class.and(guard_1, guard_2, &:itself) }

    let(:guard_1) { ->(x) { x % 5 == 0 } }
    let(:guard_2) { ->(x) { x % 2 == 0 } }

    it { is_expected.to be_defined_at(10) }
    it { is_expected.not_to be_defined_at(5) }
    it { is_expected.not_to be_defined_at(2) }
    it { is_expected.not_to be_defined_at(3) }
  end

  describe "#lift" do
    let(:lifted) { partial_function.lift }

    let(:partial_function) { Fear.case(->(v) { v != 0 }) { |x| 4 / x } }

    context "defined" do
      subject { lifted.call(2) }

      it { is_expected.to eq(Fear::Some.new(2)) }
    end

    context "not defined" do
      subject { lifted.call(0) }

      it { is_expected.to eq(Fear::None) }
    end
  end

  describe "#defined_at?" do
    let(:partial_function) { Fear.case(->(v) { v == 42 }) {} }

    it "defined at" do
      expect(partial_function.defined_at?(42)).to eq(true)
    end

    it "not defined at" do
      expect(partial_function.defined_at?(24)).to eq(false)
    end
  end

  describe "#call" do
    let(:partial_function) { Fear.case(->(v) { v != 0 }) { |x| 4 / x } }

    context "defined" do
      subject { partial_function.call(2) }

      it { is_expected.to eq(2) }
    end

    context "not defined" do
      subject { -> { partial_function.call(0) } }

      it { is_expected.to raise_error(Fear::MatchError, "partial function not defined at: 0") }
    end
  end

  describe "#to_proc", "#call" do
    let(:partial_function) { Fear.case(->(v) { v != 0 }) { |x| 4 / x }.to_proc }

    context "defined" do
      subject { partial_function.call(2) }

      it { is_expected.to eq(2) }
    end

    context "not defined" do
      subject { -> { partial_function.call(0) } }

      it { is_expected.to raise_error(Fear::MatchError, "partial function not defined at: 0") }
    end
  end

  describe "#call_or_else" do
    let(:default) { ->(x) { "division by #{x} impossible" } }
    let(:partial_function) { Fear.case(->(x) { x != 0 }) { |x| 4 / x } }

    context "defined" do
      subject { partial_function.call_or_else(2, &default) }

      it { is_expected.to eq(2) }
    end

    context "not defined" do
      subject { partial_function.call_or_else(0, &default) }

      it { is_expected.to eq("division by 0 impossible") }
    end
  end

  describe "#and_then" do
    let(:partial_function) { Fear.case(->(v) { v == 42 }) {} }
    let(:and_then) { ->(x) { x } }

    context "block given, arguments not given" do
      subject { -> { partial_function.and_then(&and_then) } }

      it { is_expected.not_to raise_error }
    end

    context "block given, argument given" do
      subject { -> { partial_function.and_then(and_then, &and_then) } }

      it { is_expected.to raise_error(ArgumentError) }
    end

    context "block given, arguments given" do
      subject { -> { partial_function.and_then(and_then, 42, &and_then) } }

      it { is_expected.to raise_error(ArgumentError) }
    end

    context "block not given, arguments not given" do
      subject { -> { partial_function.and_then } }

      it { is_expected.to raise_error(ArgumentError) }
    end

    context "block net given, arguments given" do
      subject { -> { partial_function.and_then(and_then) } }

      it { is_expected.not_to raise_error }
    end
  end

  shared_examples "#or_else" do |method_name|
    subject { is_even.__send__(method_name, is_odd).call(value) }

    let(:is_even) { Fear.case(:even?.to_proc) { |x| "#{x} is even" } }
    let(:is_odd) { Fear.case(:odd?.to_proc) { |x| "#{x} is odd" } }

    context "when left side is defined" do
      let(:value) { 42 }

      it { is_expected.to eq("42 is even") }
    end

    context "when left side is not defined" do
      let(:value) { 21 }

      it { is_expected.to eq("21 is odd") }
    end
  end

  describe "#or_else" do
    include_examples "#or_else", :or_else
  end

  describe "#|" do
    include_examples "#or_else", :|
  end
end
