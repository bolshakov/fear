RSpec.describe Fear::For do
  include Fear::For::Mixin

  context 'unary' do
    context 'Some' do
      subject do
        For(a: Fear::Some.new(2)) { a * 2 }
      end

      it { is_expected.to eq(Fear::Some.new(4)) }
    end

    context 'None' do
      subject do
        For(a: Fear::None.new) { a * 2 }
      end

      it { is_expected.to eq(Fear::None.new) }
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
      let(:first) { Fear::Some.new(2) }
      let(:second) { Fear::Some.new(3) }
      let(:third) { Fear::Some.new(4) }

      it { is_expected.to eq(Fear::Some.new(24)) }
    end

    context 'first None' do
      let(:first) { Fear::None.new }
      let(:second) { Fear::Some.new(3) }
      let(:third) { Fear::Some.new(4) }

      it { is_expected.to eq(Fear::None.new) }
    end

    context 'second None' do
      let(:first) { Fear::Some.new(2) }
      let(:second) { Fear::None.new }
      let(:third) { Fear::Some.new(4) }

      it { is_expected.to eq(Fear::None.new) }
    end

    context 'last None' do
      let(:first) { Fear::Some.new(2) }
      let(:second) { Fear::Some.new(3) }
      let(:third) { Fear::None.new }

      it { is_expected.to eq(Fear::None.new) }
    end
  end
end
