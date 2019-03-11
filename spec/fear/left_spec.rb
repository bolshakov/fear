RSpec.describe Fear::Left do
  include Fear::Either::Mixin

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { Left('value') }
  end

  let(:left) { Left('value') }

  describe '#right?' do
    subject { left }
    it { is_expected.not_to be_right }
  end

  describe '#left?' do
    subject { left }
    it { is_expected.to be_left }
  end

  describe '#select_or_else' do
    subject do
      left.select_or_else(default) { |v| v == 'value' }
    end

    context 'proc default' do
      let(:default) { -> { -1 } }

      it 'returns itself' do
        is_expected.to eq(left)
      end
    end

    context 'default' do
      let(:default) { -1 }

      it 'returns itself' do
        is_expected.to eq(left)
      end
    end
  end

  describe '#or_else' do
    subject { left.or_else { alternative } }
    let(:alternative) { Left(42) }

    it 'returns alternative' do
      is_expected.to eq(alternative)
    end
  end

  describe '#select' do
    subject do
      left.select { |v| v == 'value' }
    end

    it 'return self' do
      is_expected.to eq(left)
    end
  end

  describe '#reject' do
    subject do
      left.reject { |v| v == 'value' }
    end

    it 'return self' do
      is_expected.to eq(left)
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

      it 'returns value' do
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

  describe '#===' do
    subject { match === left }

    context 'matches erectly' do
      let(:match) { Left('value') }
      it { is_expected.to eq(true) }
    end

    context 'value does not match' do
      let(:match) { Left('error') }
      it { is_expected.to eq(false) }
    end

    context 'matches by class' do
      let(:match) { Left(String) }
      it { is_expected.to eq(true) }
    end

    context 'does not matches by class' do
      let(:match) { Left(Integer) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#match' do
    context 'matched' do
      subject do
        left.match do |m|
          m.left(->(x) { x.length < 2 }) { |x| "Left: #{x}" }
          m.left(->(x) { x.length > 2 }) { |x| "Left: #{x}" }
          m.right(->(x) { x.length > 2 }) { |x| "Right: #{x}" }
        end
      end

      it { is_expected.to eq('Left: value') }
    end

    context 'nothing matched and no else given' do
      subject do
        proc do
          left.match do |m|
            m.left(->(x) { x.length < 2 }) { |x| "Left: #{x}" }
            m.right { |_| 'noop' }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context 'nothing matched and else given' do
      subject do
        left.match do |m|
          m.left(->(x) { x.length < 2 }) { |x| "Left: #{x}" }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end
end
