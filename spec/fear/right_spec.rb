RSpec.describe Fear::Right do
  it_behaves_like Fear::RightBiased::Right do
    let(:right) { described_class.new('value') }
  end

  let(:right) { described_class.new('value') }

  describe '#right?' do
    subject { right }
    it { is_expected.to be_right }
  end

  describe '#left?' do
    subject { right }
    it { is_expected.not_to be_left }
  end

  describe '#select' do
    subject { right.select(default, &predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v == 'value' } }
      let(:default) { -1 }
      it { is_expected.to eq(right) }
    end

    context 'predicate evaluates to false and default is a proc' do
      let(:predicate) { ->(v) { v != 'value' } }
      let(:default) { -> { -1 } }
      it { is_expected.to eq(Fear::Left.new(-1)) }
    end

    context 'predicate evaluates to false and default is not a proc' do
      let(:predicate) { ->(v) { v != 'value' } }
      let(:default) { -1 }
      it { is_expected.to eq(Fear::Left.new(-1)) }
    end
  end

  describe '#swap' do
    subject { right.swap }
    it { is_expected.to eq(Fear::Left.new('value')) }
  end

  describe '#reduce' do
    subject do
      right.reduce(
        ->(left) { "Left: #{left}" },
        ->(right) { "Right: #{right}" },
      )
    end

    it { is_expected.to eq('Right: value') }
  end

  describe '#join_right' do
    context 'value is Either' do
      subject { described_class.new(value).join_right }
      let(:value) { Fear::Left.new('error') }

      it 'returns value' do
        is_expected.to eq(value)
      end
    end

    context 'value is not Either' do
      subject { proc { described_class.new('35').join_right } }

      it 'fails with type error' do
        is_expected.to raise_error(TypeError)
      end
    end
  end

  describe '#join_left' do
    context 'value is Either' do
      subject { either.join_left }
      let(:either) { described_class.new(Fear::Left.new('error')) }

      it { is_expected.to eq(either) }
    end

    context 'value is not Either' do
      subject { either.join_left }
      let(:either) { described_class.new('result') }
      it { is_expected.to eq(either) }
    end
  end
end
