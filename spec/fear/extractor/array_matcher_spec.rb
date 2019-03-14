RSpec.describe Fear::Extractor::ArrayMatcher do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  describe '#defined_at?' do
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

    context 'empty array with named splat' do
      let(:pattern) { '[*var]' }

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

      context 'identifier' do
        let(:pattern) { '[var]' }

        it { is_expected.not_to be_defined_at([]) }
        it { is_expected.to be_defined_at([1]) }
        it { is_expected.to be_defined_at([[1]]) }
      end
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

    context 'one element array with named splat' do
      let(:pattern) { '[1, *var]' }

      it { is_expected.not_to be_defined_at([]) }
      it { is_expected.to be_defined_at([1]) }
      it { is_expected.to be_defined_at([1, 2]) }
      it { is_expected.to be_defined_at([1, 2, 3]) }
      it { is_expected.not_to be_defined_at([2, 1]) }
    end

    context 'three elements array' do
      context 'with identifier in the middle' do
        let(:pattern) { '[1, var, 2]' }

        it { is_expected.not_to be_defined_at([]) }
        it { is_expected.to be_defined_at([1, 3, 2]) }
        it { is_expected.not_to be_defined_at([1, 2, 3]) }
        it { is_expected.not_to be_defined_at([1, 2, 3, 4]) }
        it { is_expected.not_to be_defined_at([1]) }
        it { is_expected.not_to be_defined_at([2]) }
      end

      context 'head and tail' do
        let(:pattern) { '[head, *tail]' }

        it { is_expected.not_to be_defined_at([]) }
        it { is_expected.to be_defined_at([1, 3, 2]) }
      end
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

      context 'with identifier at the beginning' do
        let(:pattern) { '[var, 2]' }

        it { is_expected.not_to be_defined_at([]) }
        it { is_expected.to be_defined_at([1, 2]) }
        it { is_expected.not_to be_defined_at([1, 3]) }
        it { is_expected.not_to be_defined_at([1]) }
        it { is_expected.not_to be_defined_at([2]) }
        it { is_expected.not_to be_defined_at([1, 2, 3]) }
      end
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

    context 'with identifier at the middle of an array' do
      let(:other) { [2, 1, 3] }
      let(:pattern) { '[2, var, 3]' }

      it { is_expected.to eq(Fear.some(var: 1)) }
    end

    context 'with identifier at the end of an array' do
      let(:other) { [2, 1, 3] }
      let(:pattern) { '[2, 1, var]' }

      it { is_expected.to eq(Fear.some(var: 3)) }
    end

    context 'with named splat matching tail of an array' do
      let(:other) { [2, 1, 3, 4] }
      let(:pattern) { '[2, 1, *var]' }

      it { is_expected.to eq(Fear.some(var: [3, 4])) }
    end

    context 'with named splat at the end of an array' do
      let(:other) { [2, 1] }
      let(:pattern) { '[2, 1, *var]' }

      it { is_expected.to eq(Fear.some(var: [])) }
    end

    context 'with several identifiers in an array' do
      let(:other) { [2, 1, 3] }
      let(:pattern) { '[a, 1, b]' }

      it { is_expected.to eq(Fear.some(a: 2, b: 3)) }
    end

    context 'head and tail' do
      let(:other) { [2, 1, 3] }
      let(:pattern) { '[head, *tail]' }

      it { is_expected.to eq(Fear.some(head: 2, tail: [1, 3])) }
    end

    context 'ignore head, capture tail' do
      let(:other) { [2, 1, 3] }
      let(:pattern) { '[_, *tail]' }

      it { is_expected.to eq(Fear.some(tail: [1, 3])) }
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
