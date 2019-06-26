# typed: false
RSpec.describe 'Fear::Extractor::IdentifiedMatcher' do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe '#defined_at?' do
    subject { matcher }

    let(:pattern) { 'array @ [1, *tail]' }

    it { is_expected.to be_defined_at([1, 2]) }
    it { is_expected.not_to be_defined_at('foo') }
    it { is_expected.not_to be_defined_at([2, 1]) }
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'defined' do
      let(:other) { [1, 2] }
      let(:pattern) { 'array @ [1, *tail]' }

      it { is_expected.to eq(array: [1, 2], tail: [2]) }
    end
  end

  describe '#failure_reason' do
    subject { matcher.failure_reason(other) }

    let(:pattern) { 'array @ [1, *tail]' }

    context 'match integer' do
      let(:other) { [1, 2] }

      it { is_expected.to eq(Fear.none) }
    end

    context 'does not match float' do
      let(:other) { [2, 2] }

      it { is_expected.to eq(Fear.some(<<-ERROR.strip)) }
Expected `2` to match:
array @ [1, *tail]
~~~~~~~~~^
      ERROR
    end
  end
end
