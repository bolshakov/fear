# frozen_string_literal: true

RSpec.describe Fear::PartialFunction::Empty do
  describe "#defined?" do
    subject { described_class.defined_at?(42) }

    it { is_expected.to be(false) }
  end

  describe "#call" do
    subject { -> { described_class.call(42) } }

    it { is_expected.to raise_error(Fear::MatchError, "partial function not defined at: 42") }
  end

  describe "#call_or_else" do
    subject { described_class.call_or_else(42, &default) }
    let(:default) { ->(x) { "default: #{x}" } }

    it { is_expected.to eq("default: 42") }
  end

  describe "#and_then" do
    subject { described_class.and_then { |_x| "then" } }

    it { is_expected.to eq(described_class) }
  end

  describe "#or_else" do
    subject { described_class.or_else(other) }

    let(:other) { Fear.case(proc { true }) { "other" } }

    it { is_expected.to eq(other) }
  end

  it { is_expected.to be_kind_of(Fear::PartialFunction) }
end
