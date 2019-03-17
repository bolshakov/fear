RSpec.describe Fear::Extractor::TypedIdentifierMatcher do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe '#defined_at?' do
    subject { matcher }

    let(:pattern) { 'var : Integer' }

    it { is_expected.to be_defined_at(1) }
    it { is_expected.not_to be_defined_at('foo') }
    it { is_expected.not_to be_defined_at(1.2) }

    context 'within array' do
      let(:pattern) { '[1, n : String, 2]' }

      it { is_expected.to be_defined_at([1, 'foo', 2]) }
      it { is_expected.not_to be_defined_at([1, 2, 2]) }
      it { is_expected.not_to be_defined_at([1, 'foo']) }
    end
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'defined' do
      let(:other) { 1 }
      let(:pattern) { 'var : Integer' }

      it { is_expected.to eq(var: 1) }
    end

    context 'defined within array' do
      let(:other) { [4, 2, 1, 6] }
      let(:pattern) { '[head : Integer, *tail]' }

      it { is_expected.to eq(head: 4, tail: [2, 1, 6]) }
    end
  end

  describe '#' do
    subject { matcher.failure_reason(other) }

    let(:pattern) { 'var : Integer' }

    context 'match integer' do
      let(:other) { 1 }

      it { is_expected.to eq(Fear.none) }
    end

    context 'does not match float' do
      let(:other) { 1.0 }

      it { is_expected.to eq(Fear.some(<<-ERROR.strip)) }
Expected `1.0` to match:
var : Integer
~~~~~~^
      ERROR
    end
  end
end
