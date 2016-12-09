RSpec.describe Fear::Left do
  include Fear::Either::Mixin

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { described_class.new('value') }
  end

  let(:left) { described_class.new('value') }

  describe '#right?' do
    subject { left }
    it { is_expected.not_to be_right }
  end

  describe '#left?' do
    subject { left }
    it { is_expected.to be_left }
  end

  describe '#select' do
    subject do
      left.select(default) { |v| v == 'value' }
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
    subject { left.swap }
    it { is_expected.to eq(Right('value')) }
  end

  describe '#reduce' do
    subject do
      left.reduce(
        ->(left) { "Left: #{left}" },
        ->(right) { "Right: #{right}" },
      )
    end

    it { is_expected.to eq('Left: value') }
  end

  describe '#join_right' do
    subject(:join_right) { either.join_right }

    context 'value is Either' do
      let(:either) { described_class.new(Left('error')) }
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
      let(:value) { Left('error') }

      it 'it returns value' do
        is_expected.to eq(Left('error'))
      end
    end

    context 'value is not Either' do
      subject { proc { left.join_left } }

      it 'fails with type error' do
        is_expected.to raise_error(TypeError)
      end
    end
  end
end
