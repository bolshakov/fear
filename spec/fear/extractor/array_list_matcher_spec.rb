RSpec.describe Fear::Extractor::ArrayListMatcher do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe '#defined_at??' do
    subject { matcher }

    context 'empty array' do
      let(:pattern) { '[]' }

      it { is_expected.to be_defined_at([]) }
      it { is_expected.not_to be_defined_at([1]) }
    end

    context 'empty array with splat' do
      let(:pattern) { '[*]' }

      it { is_expected.to be_defined_at([]) }
      it { is_expected.to be_defined_at([1]) }
      it { is_expected.to be_defined_at([1, 2]) }
    end

    context 'one element array' do
      let(:pattern) { '[1]' }

      it { is_expected.not_to be_defined_at([]) }
      it { is_expected.to be_defined_at([1]) }
      it { is_expected.not_to be_defined_at([1, 2]) }
      it { is_expected.not_to be_defined_at([2, 1]) }
    end

    context 'two elements array with nested matcher' do
      let(:pattern) { '[[1, *], 1]' }

      it { is_expected.not_to be_defined_at([]) }
      it { is_expected.to be_defined_at([[1], 1]) }
      it { is_expected.to be_defined_at([[1, 2], 1]) }
      it { is_expected.not_to be_defined_at([[1, 2], 2]) }
      it { is_expected.not_to be_defined_at([2, 1]) }
    end

    context 'one element array with splat' do
      let(:pattern) { '[1, *]' }

      it { is_expected.not_to be_defined_at([]) }
      it { is_expected.to be_defined_at([1]) }
      it { is_expected.to be_defined_at([1, 2]) }
      it { is_expected.to be_defined_at([1, 2, 3]) }
      it { is_expected.not_to be_defined_at([2, 1]) }
    end

    context 'two element array' do
      let(:pattern) { '[ 1, 2 ]' }

      it { is_expected.not_to be_defined_at([]) }
      it { is_expected.to be_defined_at([1, 2]) }
      it { is_expected.not_to be_defined_at([1]) }
      it { is_expected.not_to be_defined_at([2]) }
      it { is_expected.not_to be_defined_at([1, 3]) }
      it { is_expected.not_to be_defined_at([2, 2]) }
      it { is_expected.not_to be_defined_at([1, 2, 3]) }
    end
  end

  describe '#call' do
    subject { matcher.call(other) }

    context 'on the same array' do
      let(:other) { [1] }
      let(:pattern) { '[1]' }

      it { is_expected.to eq(Fear.some({})) }
    end

    context 'on another array' do
      let(:other) { [2, 1] }
      let(:pattern) { '[2, 2]' }

      it { is_expected.to eq(Fear.none) }
    end

    context 'with splat on another array' do
      let(:other) { [2, 1] }
      let(:pattern) { '[2, *]' }

      it { is_expected.to eq(Fear.some({})) }
    end
  end

  describe '#failure_reason' do
    subject { matcher.failure_reason(other) }

    context 'on the same array' do
      let(:other) { [1] }
      let(:pattern) { '[1]' }

      it { is_expected.to eq(Fear.none) }
    end

    context 'on another array' do
      let(:other) { [2, 1] }
      let(:pattern) { '[2, 2]' }

      it { is_expected.to eq(Fear.some(<<-ERROR.strip)) }
Expected 1 to match [2, 2] here:
[2, 2]
~~~^
      ERROR
    end
  end
end
