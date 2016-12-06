RSpec.describe Functional::Left do
  it_behaves_like Functional::RightBiased::Left do
    let(:left) { described_class.new('value') }
  end

  describe '#detect' do
    subject do
      described_class.new('value').detect(default) { |v| v == 'value' }
    end

    context 'proc default' do
      let(:default) { -> { -1 } }

      it 'returns Left of evaluated default' do
        is_expected.to eq(described_class.new(-1))
      end
    end

    context 'default' do
      let(:default) { -1 }

      it 'return Left of default' do
        is_expected.to eq(described_class.new(-1))
      end
    end
  end

  describe '#swap' do
    subject { described_class.new('value').swap }
    it { is_expected.to eq(Functional::Right.new('value')) }
  end

  describe '#reduce' do
    subject do
      described_class.new('value').reduce(
        ->(left) { "Left: #{left}" },
        ->(right) { "Right: #{right}" },
      )
    end

    it { is_expected.to eq('Left: value') }
  end

  describe '#join_right' do
    subject(:join_right) { either.join_right }

    context 'value is Either' do
      let(:either) { described_class.new(Functional::Left('error')) }
      it { is_expected.to eq(either) }
    end

    context 'value s not Either' do
      let(:either) { Left('error') }
      it { is_expected.to eq(either) }
    end
  end

  describe '#join_left' do
    context 'value is Either' do
      subject { either.join_left }
      let(:either) { described_class.new(value) }
      let(:value) { Functional::Left('error') }

      it 'it returns value' do
        is_expected.to eq(Left('error'))
      end
    end

    context 'value is not Either' do
      subject { proc { described_class.new('error').join_left } }

      it 'fails with type error' do
        is_expected.to raise_error(TypeError)
      end
    end
  end
end
