RSpec.describe Fear::For do
  context 'unary' do
    context 'Some' do
      subject do
        For(Some(2)) { |a| a * 2 }
      end

      it { is_expected.to eq(Some(4)) }
    end

    context 'None' do
      subject do
        For(None()) { |a| a * 2 }
      end

      it { is_expected.to eq(None()) }
    end
  end

  context 'arrays' do
    subject do
      For([1, 2], [2, 3], [3, 4]) do |a, b, c|
        a * b * c
      end
    end

    it { is_expected.to eq([6, 8, 9, 12, 12, 16, 18, 24]) }
  end

  context 'ternary' do
    subject do
      For(first, second, third) do |a, b, c|
        a * b * c
      end
    end

    context 'all Same' do
      let(:first) { Some(2) }
      let(:second) { Some(3) }
      let(:third) { Some(4) }

      it { is_expected.to eq(Some(24)) }
    end

    context 'first is None' do
      let(:first) { None() }
      let(:second) { Some(3) }
      let(:third) { Some(4) }

      it { is_expected.to eq(None()) }
    end

    context 'second is None' do
      let(:first) { Some(2) }
      let(:second) { None() }
      let(:third) { Some(4) }

      it { is_expected.to eq(None()) }
    end

    context 'last is None' do
      let(:first) { Some(2) }
      let(:second) { Some(3) }
      let(:third) { None() }

      it { is_expected.to eq(None()) }
    end

    context 'all Same in lambdas' do
      let(:first) { proc { Some(2) } }
      let(:second) { proc { Some(3) } }
      let(:third) { proc { Some(4) } }

      it { is_expected.to eq(Some(24)) }
    end

    context 'first is None in lambda, second is failure in lambda' do
      let(:first) { proc { None() } }
      let(:second) { proc { raise 'kaboom' } }
      let(:third) { proc {} }

      it 'returns None without evaluating second and third' do
        is_expected.to eq(None())
      end
    end

    context 'second is None in lambda, third is failure in lambda' do
      let(:first) { Some(2) }
      let(:second) { proc { None() } }
      let(:third) { proc { raise 'kaboom' } }

      it 'returns None without evaluating third' do
        is_expected.to eq(None())
      end
    end
  end

  context 'refer to previous variable from lambda' do
    subject do
      For(first, second, third) do |_, b, c|
        b * c
      end
    end

    let(:first) { Some(Some(2)) }
    let(:second) { ->(a) { a.map { |x| x * 2 } } }
    let(:third) { proc { Some(3) } }

    it { is_expected.to eq(Some(12)) }
  end
end
