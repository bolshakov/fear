# frozen_string_literal: true

RSpec.describe Fear::None do
  it_behaves_like Fear::RightBiased::Left do
    let(:left) { Fear.none }
  end

  subject(:none) { Fear.none }

  describe "#get" do
    subject { proc { none.get } }
    it { is_expected.to raise_error(Fear::NoSuchElementError) }
  end

  describe "#or_nil" do
    subject { none.or_nil }
    it { is_expected.to eq(nil) }
  end

  describe "#or_else" do
    subject { none.or_else { alternative } }
    let(:alternative) { Fear.some(42) }

    it "returns alternative" do
      is_expected.to eq(alternative)
    end
  end

  describe "#empty?" do
    subject { none.empty? }
    it { is_expected.to eq(true) }
  end

  describe "#select" do
    subject { none.select { |value| value > 42 } }

    it "always return None" do
      is_expected.to eq(Fear.none)
    end
  end

  describe "#reject" do
    subject { none.reject { |value| value > 42 } }

    it "always return None" do
      is_expected.to eq(Fear.none)
    end
  end

  describe ".new" do
    subject { Fear::None.class.new }

    it { is_expected.to eq(Fear::None) }
  end

  describe ".inherited" do
    subject { -> { Class.new(Fear.none.class) } }

    it "raises error" do
      is_expected.to raise_error(RuntimeError, "you are not allowed to inherit from NoneClass, use Fear::None instead")
    end
  end

  describe "#to_s" do
    subject { none.to_s }

    it { is_expected.to eq("#<Fear::NoneClass>") }
  end

  describe "#inspect" do
    subject { none.inspect }

    it { is_expected.to eq("#<Fear::NoneClass>") }
  end

  describe "#===" do
    context "None" do
      subject { Fear::None === none }

      it { is_expected.to eq(true) }
    end

    context "Fear::Some" do
      subject { Fear::None === Fear.some(4) }

      it { is_expected.to eq(false) }
    end

    context "Integer" do
      subject { Fear::None === 4 }

      it { is_expected.to eq(false) }
    end
  end

  describe "#match" do
    context "matched" do
      subject do
        none.match do |m|
          m.some { |x| x * 2 }
          m.none { "noop" }
        end
      end

      it { is_expected.to eq("noop") }
    end

    context "nothing matched and no else given" do
      subject do
        proc do
          none.match do |m|
            m.some { |x| x * 2 }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context "nothing matched and else given" do
      subject do
        none.match do |m|
          m.some { |x| x * 2 }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end
end
