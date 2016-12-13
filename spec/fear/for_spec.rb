RSpec.describe Fear::For do
  context 'unary' do
    context 'Some' do
      subject do
        For(a: Some(2)) { a * 2 }
      end

      it { is_expected.to eq(Some(4)) }
    end

    context 'None' do
      subject do
        For(a: None()) { a * 2 }
      end

      it { is_expected.to eq(None()) }
    end
  end

  context 'arrays' do
    subject do
      For(a: [1, 2], b: [2, 3], c: [3, 4]) do
        a * b * c
      end
    end
    it { is_expected.to eq([6, 8, 9, 12, 12, 16, 18, 24]) }
  end

  context 'ternary' do
    subject do
      For(a: first, b: second, c: third) do
        a * b * c
      end
    end

    context 'all Same' do
      let(:first) { Some(2) }
      let(:second) { Some(3) }
      let(:third) { Some(4) }

      it { is_expected.to eq(Some(24)) }
    end

    context 'first None' do
      let(:first) { None() }
      let(:second) { Some(3) }
      let(:third) { Some(4) }

      it { is_expected.to eq(None()) }
    end

    context 'second None' do
      let(:first) { Some(2) }
      let(:second) { None() }
      let(:third) { Some(4) }

      it { is_expected.to eq(None()) }
    end

    context 'last None' do
      let(:first) { Some(2) }
      let(:second) { Some(3) }
      let(:third) { None() }

      it { is_expected.to eq(None()) }
    end
  end
end
