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

    context 'single argument extractor with array as an argument' do
      let(:pattern) { 'Fear::Some([1, 2])' }

      it { is_expected.to be_defined_at(Fear.some([1, 2])) }
      it { is_expected.not_to be_defined_at(Fear.some([1, 1])) }
      it { is_expected.not_to be_defined_at(Fear.some('foo')) }
    end

    context 'multiple arguments extractor' do
      let(:pattern) { 'Date(2017, month, _)' }

      it { is_expected.to be_defined_at(Date.parse('2017-02-15')) }
      it { is_expected.not_to be_defined_at(Date.parse('2018-02-15')) }
      it { is_expected.not_to be_defined_at('foo') }
    end

    context 'Struct' do
      StructDate = ::Struct.new(:year, :month, :day)

      let(:pattern) { 'StructDate(2017, month, _)' }

      it { is_expected.to be_defined_at(StructDate.new(2017, 2, 15)) }
      it { is_expected.not_to be_defined_at(StructDate.new(2018, 2, 15)) }
    end
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'single argument extractor' do
      let(:pattern) { 'Fear::Some(a : Integer)' }
      let(:other) { Fear.some(42) }

      it { is_expected.to eq(a: 42) }
    end

    context 'multiple arguments extractor' do
      let(:pattern) { 'Date(2017, month, day)' }
      let(:other) { Date.parse('2017-02-15') }

      it { is_expected.to eq(month: 2, day: 15) }
    end
  end

  describe '#failure_reason' do
    subject { matcher.failure_reason(other) }

    context 'no argument extractor' do
      let(:pattern) { 'IsEven()' }

      context 'defined' do
        let(:other) { 42 }

        it { is_expected.to eq(Fear.none) }
      end

      context 'not defined' do
        let(:other) { 43 }

        it { is_expected.to eq(Fear.some(<<-MSG.strip)) }
Expected `43` to match:
IsEven()
^
        MSG
      end
    end

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
~~~~~~~~~~~~~~~^
        MSG
      end
    end

    context 'single argument extractor, array argument' do
      let(:pattern) { 'Fear::Some([1, 2])' }

      context 'defined' do
        let(:other) { Fear.some([1, 2]) }

        it { is_expected.to eq(Fear.none) }
      end

      context 'not defined' do
        let(:other) { Fear.some([1, 1]) }

        it { is_expected.to eq(Fear.some(<<-MSG.strip)) }
Expected `1` to match:
Fear::Some([1, 2])
~~~~~~~~~~~~~~~^
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
~~~~~~~~~~~^
        MSG
      end
    end
  end
end
