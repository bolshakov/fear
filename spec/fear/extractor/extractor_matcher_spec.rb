RSpec.describe Fear::Extractor::ExtractorMatcher do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe '#defined_at?' do
    subject { matcher }

    context 'boolean extractor' do
      let(:pattern) { 'IsEven()' }

      it { is_expected.to be_defined_at(42) }
      it { is_expected.not_to be_defined_at(43) }
      it { is_expected.not_to be_defined_at('foo') }
    end

    context 'single argument extractor' do
      let(:pattern) { 'Fear::Some(a : Integer)' }

      it { is_expected.to be_defined_at(Fear.some(42)) }
      it { is_expected.not_to be_defined_at('foo') }
      it { is_expected.not_to be_defined_at(Fear.some('foo')) }
    end

    context 'multiple arguments extractor' do
      let(:pattern) { 'Date(2017, month, _)' }

      it { is_expected.to be_defined_at(Date.parse('2017-02-15')) }
      it { is_expected.not_to be_defined_at(Date.parse('2018-02-15')) }
      it { is_expected.not_to be_defined_at('foo') }
    end
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'single argument extractor' do
      let(:pattern) { 'Fear::Some(a : Integer)' }

      context 'defined' do
        let(:other) { Fear.some(42) }

        it { is_expected.to eq(Fear.some(a: 42)) }
      end

      context 'not defined' do
        let(:other) { Fear.some('42') }

        it { is_expected.to eq(Fear.none) }
      end
    end

    context 'multiple arguments extractor' do
      let(:pattern) { 'Date(2017, month, day)' }

      context 'defined' do
        let(:other) { Date.parse('2017-02-15') }

        it { is_expected.to eq(Fear.some(month: 2, day: 15)) }
      end

      context 'not defined' do
        let(:other) { Date.parse('2018-02-15') }

        it { is_expected.to eq(Fear.none) }
      end
    end
  end

  describe '#failure_reason' do
    subject { matcher.failure_reason(other) }

    context 'single argument extractor' do
      let(:pattern) { 'Fear::Some(a : Integer)' }

      context 'defined' do
        let(:other) { Fear.some(42) }

        it { is_expected.to eq(Fear.none) }
      end

      context 'not defined' do
        let(:other) { Fear.some('42') }

        it { is_expected.to eq(Fear.some(<<-MSG.strip)) }
Expected `"42"` to match:
Fear::Some(a : Integer)
~~~~~~~~~~~^
        MSG
      end
    end

    context 'multiple arguments extractor' do
      let(:pattern) { 'Date(year, 02, day)' }

      context 'defined' do
        let(:other) { Date.parse('2017-02-15') }

        it { is_expected.to eq(Fear.none) }
      end

      context 'not defined' do
        let(:other) { Date.parse('2017-04-15') }

        it { is_expected.to eq(Fear.some(<<-MSG.strip)) }
Expected `4` to match:
Date(year, 02, day)
~~~~~~~~~~^
        MSG
      end
    end
  end
end
