# frozen_string_literal: true

RSpec.describe Fear::Extractor::ValueMatcher, "String" do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe "#defined_at?" do
    subject { matcher }

    context "double quotas" do
      let(:pattern) { %("foo") }

      it { is_expected.to be_defined_at("foo") }
      it { is_expected.not_to be_defined_at("boo") }
      it { is_expected.not_to be_defined_at(2) }

      context "single quotes inside" do
        let(:pattern) { %("f'o'o") }

        it { is_expected.to be_defined_at(%(f'o'o)) }
        it { is_expected.not_to be_defined_at(%(f"o"o)) }
      end

      context "escaped double quotes inside" do
        let(:pattern) { '"f\"oo"' }

        it { is_expected.to be_defined_at('f"oo') }
        it { is_expected.not_to be_defined_at("f'oo") }
      end
    end

    context "single quotas" do
      let(:pattern) { %('foo') }

      it { is_expected.to be_defined_at("foo") }
      it { is_expected.not_to be_defined_at("boo") }
      it { is_expected.not_to be_defined_at(2) }

      context "double quotes inside" do
        let(:pattern) { %('f"o"o') }

        it { is_expected.to be_defined_at(%(f"o"o)) }
        it { is_expected.not_to be_defined_at(%(f'o'o)) }
      end

      context "escaped single quotes inside" do
        let(:pattern) { "'f\\'oo'" }

        it { is_expected.to be_defined_at("f\\'oo") }
        it { is_expected.not_to be_defined_at("f'oo") }
      end
    end
  end

  describe "#call" do
    subject { matcher.(other) }

    let(:pattern) { '"foo"' }

    context "defined" do
      let(:other) { "foo" }

      it { is_expected.to eq({}) }
    end
  end

  describe "#failure_reason" do
    subject { matcher.failure_reason(other) }

    context "match" do
      let(:other) { "foo" }
      let(:pattern) { '"foo"' }

      it { is_expected.to eq(Fear.none) }
    end

    context "does not match" do
      let(:other) { "bar" }
      let(:pattern) { '"foo"' }

      it { is_expected.to eq(Fear.some(<<~ERROR.strip)) }
        Expected `"bar"` to match:
        "foo"
        ^
      ERROR
    end
  end
end
