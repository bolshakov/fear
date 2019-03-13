RSpec.describe Fear::Extractor::IntegerMatcher do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse('1').to_matcher }

  describe '#defined_at??' do
    subject { matcher }

    it { is_expected.to be_defined_at(1) }
    it { is_expected.to be_defined_at(1.0) }
    it { is_expected.not_to be_defined_at(2) }
    it { is_expected.not_to be_defined_at('1') }
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'defined' do
      let(:other) { 1 }

      it { is_expected.to eq(Fear.some({})) }
    end

    context 'not defined' do
      let(:other) { 2 }

      it { is_expected.to eq(Fear.none) }
    end
  end

  describe '#failure_reason' do
    subject { matcher.failure_reason(other) }

    context 'match integer' do
      let(:other) { 1 }
      let(:pattern) { '1' }

      it { is_expected.to eq(Fear.none) }
    end

    context 'match float' do
      let(:other) { 1.0 }
      let(:pattern) { '1' }

      it { is_expected.to eq(Fear.none) }
    end

    context 'does not match another integer' do
      let(:other) { 2 }
      let(:pattern) { '1' }

      it { is_expected.to eq(Fear.some(<<-ERROR.strip)) }
Expected 2 to match 1 here:
1
^
      ERROR
    end
  end
end
