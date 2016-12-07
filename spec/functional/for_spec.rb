RSpec.describe Functional::For do
  def For(**args, &block) # rubocop: disable Style/MethodName
    Functional::For.new(**args).call(&block)
  end

  context 'unary' do
    context 'Functional::Some' do
      subject do
        For(a: Functional::Some.new(2)) { a * 2 }
      end

      it { is_expected.to eq(Functional::Some.new(4)) }
    end

    context 'Functional::None' do
      subject do
        For(a: Functional::None.new) { a * 2 }
      end

      it { is_expected.to eq(Functional::None.new) }
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
      let(:first) { Functional::Some.new(2) }
      let(:second) { Functional::Some.new(3) }
      let(:third) { Functional::Some.new(4) }

      it { is_expected.to eq(Functional::Some.new(24)) }
    end

    context 'first None' do
      let(:first) { Functional::None.new }
      let(:second) { Functional::Some.new(3) }
      let(:third) { Functional::Some.new(4) }

      it { is_expected.to eq(Functional::None.new) }
    end

    context 'second None' do
      let(:first) { Functional::Some.new(2) }
      let(:second) { Functional::None.new }
      let(:third) { Functional::Some.new(4) }

      it { is_expected.to eq(Functional::None.new) }
    end

    context 'last None' do
      let(:first) { Functional::Some.new(2) }
      let(:second) { Functional::Some.new(3) }
      let(:third) { Functional::None.new }

      it { is_expected.to eq(Functional::None.new) }
    end
  end
end
